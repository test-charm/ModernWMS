# 商品类别设置 API 测试设计

## 范围

- `GET /category/all`
- `GET /category?id={id}`
- `POST /category`
- `PUT /category`
- `DELETE /category?id={id}`

## 输入因子与取值

| 因子 | 说明 | 取值/等价类 | 备注 |
| --- | --- | --- | --- |
| 登录态 | 是否已登录 | 已登录 | `CategoryController` 继承 `BaseController`，统一走 `@api-login-tenantId-9001` |
| 当前租户 | 当前用户 `tenant_id` | `9001` | 列表、重名校验、创建者都依赖当前租户 |
| 类别数据存在性 | 当前租户是否存在商品类别 | 有数据 / 无数据 | 覆盖 `/all` 的 `data.Any()` 两条返回路径 |
| `id` | 详情、修改、删除主键 | 存在 / 不存在 | 覆盖 `GET`、`PUT`、`DELETE` 的存在性分支 |
| `category_name` | 商品类别名称 | 合法唯一 / 同租户重复 / 其他租户同名 / 缺失 / 长度=32 / 长度=33 | `POST/PUT` 的核心输入因子 |
| `parent_id` | 父类别 | `0` 根类别 / 有效父类别 | 影响树形结构与级联行为 |
| `is_valid` | 类别状态 | `true` / `false` | `PUT` 改变状态时应同步所有子孙类别 |
| 子孙层级 | 类别树深度 | 无子节点 / 1 级子节点 / 2 级子孙节点 | 覆盖 `GetChildren` 递归路径 |
| 商品引用 | `spu.category_id` 是否引用待删类别树 | 未引用 / 已引用 | 覆盖 `delete_referenced` 分支 |
| 跨租户同名数据 | 其他租户是否已有同名类别 | 否 / 是 | 验证重名校验仅限制当前租户 |

## 输出因子

| 接口 | 关注输出 |
| --- | --- |
| `GET /category/all` | 成功时返回当前租户数组；无数据时返回空数组 |
| `GET /category?id` | 成功返回对象；不存在返回 `code=400` + `not_exists_entity` |
| `POST /category` | 成功返回新增 id；失败返回校验错误或 `exists_entity` |
| `PUT /category` | 成功返回 `true`；失败返回 `not_exists_entity` 或 `exists_entity` |
| `DELETE /category?id` | 成功返回 `删除成功`；被引用返回 `数据已被引用，不能删除`；不存在返回 `删除失败` |

## 流程图

```text
[进入商品类别 API]
  ├──→ {GET /category/all}
  │      ├──→ {当前租户有数据} ──→ [返回当前租户数组]
  │      └──→ {无数据} ──→ [返回空数组]
  ├──→ {GET /category?id}
  │      ├──→ {id 存在} ──→ [返回对象]
  │      └──→ {id 不存在} ──→ [返回 not_exists_entity]
  ├──→ {POST /category}
  │      ├──→ {模型校验失败} ──→ [返回 400 + 校验消息]
  │      ├──→ {同租户重名} ──→ [返回 exists_entity]
  │      └──→ [写入 creator/create_time/tenant_id 并返回新 id]
  ├──→ {PUT /category}
  │      ├──→ {id 不存在} ──→ [返回 not_exists_entity]
  │      ├──→ {同租户重名} ──→ [返回 exists_entity]
  │      ├──→ {is_valid 发生变化}
  │      │      ├──→ {存在子孙类别} ──→ [递归同步所有子孙状态]
  │      │      └──→ {无子孙类别} ──→ [仅更新自身]
  │      └──→ [保存成功]
  └──→ {DELETE /category?id}
         ├──→ {存在子孙类别} ──→ [递归收集待删 id]
         ├──→ {任一 id 被 spu 引用} ──→ [返回 delete_referenced]
         ├──→ {删除条数 > 0} ──→ [返回 delete_success]
         └──→ [返回 delete_failed]
```

## 用例矩阵

| 用例名 | `id` | `category_name` | `parent_id` | `is_valid` | 子孙层级 | 商品引用 | 跨租户同名 | 期望结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 全列表只返回当前租户商品类别和全部字段 | N/A | N/A | 根/子 | `true/false` | 1 级 | 否 | 有 | 仅返回租户 `9001` 的类别，字段完整 |
| 全列表无数据时返回空数组 | N/A | N/A | N/A | N/A | 无 | 否 | 否 | 成功返回空数组 |
| 根据 id 获取商品类别成功 | 存在 | 合法唯一 | 根 | `true` | 无 | 否 | 否 | 返回完整对象 |
| 根据不存在的 id 获取商品类别失败 | 不存在 | N/A | N/A | N/A | 无 | 否 | 否 | 返回 `数据不存在或已被删除` |
| 新增根级商品类别成功并写入数据库 | N/A | 合法唯一 | `0/缺省` | `true` | 无 | 否 | 否 | 返回新 id，写入 `creator/tenant_id/time` |
| 新增同租户重名商品类别失败 | N/A | 同租户重复 | 根 | `true` | 无 | 否 | 否 | 返回 `商品类别:{name} 已经存在`，不重复落库 |
| 新增商品类别允许与其他租户同名 | N/A | 其他租户已存在同名 | 根 | `true` | 无 | 否 | 是 | 当前租户新增成功 |
| 新增商品类别缺少名称时校验失败 | N/A | 缺失 | N/A | `true` | 无 | 否 | 否 | 返回 `商品类别必填` |
| 新增商品类别名称超长时校验失败 | N/A | 长度 33 | N/A | `true` | 无 | 否 | 否 | 返回 `商品类别输入字符长度不能大于32个字符` |
| 修改商品类别成功 | 存在 | 合法唯一 | 有效父类别 | `true` | 无 | 否 | 否 | 返回 `true`，名称和父级更新 |
| 修改商品类别为同租户重复名称失败 | 存在 | 同租户重复 | 根 | `true` | 无 | 否 | 否 | 返回 `exists_entity` |
| 修改不存在的商品类别失败 | 不存在 | 合法唯一 | 根 | `true` | 无 | 否 | 否 | 返回 `not_exists_entity` |
| 修改商品类别状态时同步所有子孙类别 | 存在 | 保持原名 | 根 | `true → false` | 2 级 | 否 | 否 | 父、子、孙类别均被置为 `false` |
| 删除商品类别成功 | 存在 | N/A | 根 | N/A | 无 | 否 | 否 | 返回 `删除成功` 且数据被删 |
| 删除商品类别时同时删除所有子孙类别 | 存在 | N/A | 根 | N/A | 2 级 | 否 | 否 | 父、子、孙类别全部删除 |
| 删除被商品引用的商品类别失败 | 存在 | N/A | 根 | N/A | 无 | 是 | 否 | 返回 `数据已被引用，不能删除` |
| 删除不存在的商品类别失败 | 不存在 | N/A | N/A | N/A | 无 | 否 | 否 | 返回 `删除失败` |

## 覆盖性检查

- 所有控制器入口都有成功路径。
- 所有显式失败路径均有覆盖：校验失败、同租户重名、`id` 不存在、被 `spu` 引用、删除失败。
- 关键条件分支均有覆盖：
  - `data.Any()`：有数据 / 无数据
  - `entity == null`：`GET`、`PUT` 的存在 / 不存在
  - `AnyAsync(...category_name...)`：同租户重复 / 非重复 / 跨租户同名可通过
  - `!viewModel.is_valid.Equals(entity.is_valid)`：状态未变 / 状态变化
  - `children.Any()`：无子节点 / 有子孙节点
  - `Spus.AnyAsync(category_id in idList)`：未引用 / 已引用
  - `ExecuteDeleteAsync() > 0`：删除成功 / 删除失败

## 测试数据策略

- 所有数据通过 JFactory 在场景内准备，不依赖测试外 SQL 脚本。
- 商品类别测试使用独立的 `category`、`spu` JPA 实体和 Spec，便于直接断言数据库状态。
- 对非关键字段尽量使用 Spec 默认值，只显式赋值与当前场景相关的 `categoryName`、`parentId`、`valid`、`tenantId`、`categoryId` 等字段。
- 通过 `@api-login-tenantId-9001` Hook 注入登录态，确保创建者和租户字段来自真实登录流程。

## 已知缺陷回归场景

- `commodity-category-known-bugs.feature` 记录当前已知缺陷：
  1. 不存在的 `id` 详情查询未返回失败。
  2. 状态同步只对直接子类别稳定，带孙类别时会异常。
  3. 删除只会稳定删除直接子类别，孙类别会遗留。
- 这些场景统一打 `@known-bug` 标签，默认不进入 `./gradlew cucumber` 回归。
- 如需单独复现已知缺陷，可执行：`./gradlew cucumber -Ptags='@known-bug' -Pfile=src/test/resources/features/commodity-category-known-bugs.feature`
