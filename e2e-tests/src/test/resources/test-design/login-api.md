# 用户登录 API 测试设计

## 被测对象

- 接口：`POST /login`
- 输入模型：`user_name`、`password`
- 关键实现：
  - `LoginInputViewModel`：`user_name` 必填且最大 128；`password` 必填且最大 64
  - `ViewModelActionFiter`：模型校验失败时返回 `Code=400`、`IsSuccess=false`、`Data=null`
  - `AccountService.Login`：
    - 账号可用 `user_name` 或 `user_num`
    - 密码可用明文匹配 `auth_string == password`
    - 也可用前端 MD5 结果匹配 `auth_string == md5(password)`
  - `AccountController.LoginAsync`：
    - 登录成功时返回用户信息、`access_token`、`refresh_token`、`expire`
    - 登录失败时返回本地化消息 `登录失败`

## 输入因子与取值分析

### 输入因子

| 因子 | 说明 | 等价类/边界值 |
| --- | --- | --- |
| `user_name` | 登录标识 | 1. 合法且命中 `user_name`  2. 合法且命中 `user_num`  3. 合法但不存在  4. 缺失/空  5. 长度=128  6. 长度=129 |
| `password` | 登录密码 | 1. 合法明文且服务端 MD5 后命中  2. 合法 MD5 串且直接命中 `auth_string`  3. 合法但错误  4. 缺失/空  5. 长度=64  6. 长度=65 |
| 用户数据存在性 | 数据准备 | 1. 存在匹配用户  2. 不存在匹配用户 |
| 用户角色关联 | `user.user_role == userrole.role_name` 且 `tenant_id` 一致 | 1. 关联存在  2. 关联缺失 |

### 输出因子

| 因子 | 说明 | 典型取值 |
| --- | --- | --- |
| `IsSuccess` | 业务是否成功 | `true` / `false` |
| `Code` | 业务状态码 | `200` / `400` |
| `ErrorMessage` | 错误信息 | `""` / `登录失败` / `员工名称必填` / `password必填` / `员工名称输入字符长度不能大于128个字符` / `password输入字符长度不能大于64个字符` |
| `Data` | 成功/失败时返回体 | 成功时为用户编号、用户名、角色、租户、token、refresh token、expire；失败时为 `null` |

## 流程图

```text
[收到 POST /login]
  ──→ {模型校验通过?}
       ├─ N ──→ [返回 400 + 校验错误 + Data=null]
       └─ Y ──→ [按 user_name/user_num + tenant_id 关联查询用户和角色]
                 ──→ {查到候选用户?}
                      ├─ N ──→ [返回 400 + 登录失败 + Data=null]
                      └─ Y ──→ {auth_string == md5(password)?}
                               ├─ Y ──→ [返回 200 + token/refresh token]
                               └─ N ──→ {auth_string == password?}
                                        ├─ Y ──→ [返回 200 + token/refresh token]
                                        └─ N ──→ [返回 400 + 登录失败 + Data=null]
```

## 最短路径用例设计

| 用例名 | user_name | password | 预置数据 | 期望输出 | 覆盖点 |
| --- | --- | --- | --- | --- | --- |
| 用户名+明文密码登录成功 | `login-user-plain` | `plain-secret` | 存在用户：`user_name=login-user-plain`，`user_num=login-num-plain`，`auth_string=md5(plain-secret)`；存在匹配角色 | `IsSuccess=true`，`Code=200`，`expire=60`，返回 token/refresh token | `user_name` 命中；`md5(password)` 分支命中 |
| 工号+MD5密码登录成功 | `login-num-md5` | `md5("md5-secret")` | 存在用户：`user_name=login-user-md5`，`user_num=login-num-md5`，`auth_string=md5-secret` 的 MD5 值；存在匹配角色 | `IsSuccess=true`，`Code=200`，`expire=60`，返回 token/refresh token | `user_num` 命中；`auth_string == password` 分支命中 |
| 合法最大长度用户名和密码登录成功 | 长度 128 的用户名 | 长度 64 的密码 | 存在用户，`auth_string=md5(64位密码)`；存在匹配角色 | `IsSuccess=true`，`Code=200`，`expire=60`，返回 token/refresh token | `user_name`、`password` 的合法边界值 |
| 密码错误登录失败 | `login-user-wrong-password` | `wrong-secret` | 存在用户与角色，但密码不匹配 | `IsSuccess=false`，`Code=400`，`ErrorMessage=登录失败`，`Data=null` | 已命中用户但两条密码分支均失败 |
| 用户不存在登录失败 | `missing-user` | `any-secret` | 不准备用户 | `IsSuccess=false`，`Code=400`，`ErrorMessage=登录失败`，`Data=null` | 用户查询为空 |
| 角色关联缺失登录失败 | `login-user-no-role` | `no-role-secret` | 仅准备用户，不准备匹配角色 | `IsSuccess=false`，`Code=400`，`ErrorMessage=登录失败`，`Data=null` | Join 关联缺失 |
| 缺少用户名校验失败 | 缺失 | `valid-secret` | 不要求 | `IsSuccess=false`，`Code=400`，`ErrorMessage=员工名称必填`，`Data=null` | `user_name` Required |
| 缺少密码校验失败 | `login-user` | 缺失 | 不要求 | `IsSuccess=false`，`Code=400`，`ErrorMessage=password必填`，`Data=null` | `password` Required |
| 用户名超长校验失败 | 129 个字符 | `valid-secret` | 不要求 | `IsSuccess=false`，`Code=400`，`ErrorMessage=员工名称输入字符长度不能大于128个字符`，`Data=null` | `user_name` 上界外 |
| 密码超长校验失败 | `login-user` | 65 个字符 | 不要求 | `IsSuccess=false`，`Code=400`，`ErrorMessage=password输入字符长度不能大于64个字符`，`Data=null` | `password` 上界外 |

## 覆盖性检查

### 1. 代码路径覆盖

- 模型校验失败路径：已由“缺少用户名 / 缺少密码 / 用户名超长 / 密码超长”覆盖
- 查询无用户路径：已由“用户不存在登录失败”“角色关联缺失登录失败”覆盖
- 查询到用户但密码不匹配路径：已由“密码错误登录失败”覆盖
- 明文密码成功路径：已由“用户名+明文密码登录成功”覆盖
- MD5 密码成功路径：已由“工号+MD5密码登录成功”覆盖
- 合法边界成功路径：已由“合法最大长度用户名和密码登录成功”覆盖

### 2. 输入因子取值覆盖

- `user_name`：命中用户名、命中工号、不存在、缺失、长度=128、超长均已覆盖
- `password`：明文成功、MD5 成功、错误、缺失、长度=64、超长均已覆盖
- 用户角色关联存在：成功/密码错误场景覆盖
- 用户角色关联缺失：角色关联缺失场景覆盖
- 用户缺失：用户不存在场景覆盖

### 3. 条件分支逻辑点覆盖

- `(user.user_name == input || user.user_num == input)`：
  - 左侧真：用户名成功
  - 左侧假且右侧真：工号成功
  - 左右都假：用户不存在
- `(cipher == md5(password) || cipher == password)`：
  - 左侧真：明文密码成功
  - 左侧假且右侧真：MD5 密码成功
  - 左右都假：密码错误

## 测试数据策略

- 每个成功/失败业务场景都通过 JFactory 创建登录所需数据，不依赖系统初始化的 `admin`
- 校验场景不依赖数据库数据
- 清理策略仅删除测试租户数据，不影响系统初始化数据
- 对非测试重点字段尽量依赖 `Users` Spec 默认值，只在 `user_name`、`user_num`、`auth_string` 等关键差异字段上显式赋值
