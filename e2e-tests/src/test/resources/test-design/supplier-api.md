# 供应商信息 API 测试设计

## 范围

- `POST /supplier/list`
- `GET /supplier/all`
- `GET /supplier?id={id}`
- `POST /supplier`
- `PUT /supplier`
- `DELETE /supplier?id={id}`
- `POST /supplier/excel`

## 输入因子与取值

| 因子 | 说明 | 取值/等价类 | 备注 |
| --- | --- | --- | --- |
| 登录态 | 是否已登录 | 已登录 | 供应商控制器继承 `BaseController`，统一走 `@api-login` |
| 当前租户 | 当前用户 `tenant_id` | `9001` | Hook 固定为 `9001`，避免数据“假通过” |
| `sqlTitle` | 列表模式 | 空字符串、`select` | `select` 时只返回 `is_valid=true` |
| `searchObjects` | 列表查询条件 | 空、`Contains(supplier_name)` | 覆盖 `Any()` 与 `Contains` 分支 |
| `supplier_name` | 供应商名称 | 合法唯一、同租户重复、缺失、超长(257) | `POST/PUT/Excel` 的核心判定因子 |
| `is_valid` | 是否有效 | `true`、`false` | 影响 `/supplier/list` 的 `select` 分支 |
| `tenant_id` | 供应商归属租户 | 当前租户 `9001`、其他租户 `9002` | `/all`、`list`、重名校验、excel 重名校验均受其影响 |
| `id` | 主键 | 存在、不存在 | 覆盖 `GET/PUT/DELETE` 分支 |
| Excel 行集 | 导入数组 | 全部唯一、文件内重复、与库内重复 | 覆盖 `ExcelAsync` 三条返回路径 |

## 输出因子

| 接口 | 关注输出 |
| --- | --- |
| `/supplier/list` | `data.totals`、`data.rows` 过滤结果 |
| `/supplier/all` | 仅返回当前租户数据 |
| `GET /supplier` | 成功返回对象；不存在返回 `code=400` |
| `POST /supplier` | 成功返回新增 id；失败返回重名/校验错误 |
| `PUT /supplier` | 成功返回 `true`；失败返回重名/不存在 |
| `DELETE /supplier` | 成功返回“删除成功”；失败返回“删除失败” |
| `/supplier/excel` | 成功返回“保存成功”；失败返回 `isSuccess=false` 且不落库 |

## 流程图

```text
[进入供应商 API]
  ├──→ {POST /supplier/list}
  │      ├──→ {searchObjects 为空} ──→ [按租户分页]
  │      └──→ {searchObjects 有值} ──→ [按 Contains 过滤]
  │                               └──→ {sqlTitle=select} ──→ [仅保留 is_valid=true]
  ├──→ {GET /supplier/all} ──→ [按租户返回全部]
  ├──→ {GET /supplier?id}
  │      ├──→ {id 存在} ──→ [返回对象]
  │      └──→ {id 不存在} ──→ [返回 not_exists_entity]
  ├──→ {POST /supplier}
  │      ├──→ {模型校验失败} ──→ [返回 400]
  │      ├──→ {同租户重名} ──→ [返回 exists_entity]
  │      └──→ [保存成功并返回 id]
  ├──→ {PUT /supplier}
  │      ├──→ {同租户重名} ──→ [返回 exists_entity]
  │      ├──→ {id 不存在} ──→ [返回 not_exists_entity]
  │      └──→ [保存成功]
  ├──→ {DELETE /supplier?id}
  │      ├──→ {id 存在} ──→ [删除成功]
  │      └──→ {id 不存在} ──→ [删除失败]
  └──→ {POST /supplier/excel}
         ├──→ {文件内重名} ──→ [返回 exists_entity]
         ├──→ {与库内重名} ──→ [返回 exists_entity]
         └──→ [批量保存成功]
```

## 用例矩阵

| 用例名 | list 查询 | `sqlTitle` | `supplier_name` | `is_valid` | `tenant_id` | `id` | Excel 行集 | 期望结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| list-返回当前租户全部数据 | 空 | 空 | N/A | `true/false` | `9001/9002` | N/A | N/A | 返回当前租户全部供应商，含无效数据 |
| list-select-只返回匹配且有效数据 | `Contains(match)` | `select` | 匹配/不匹配 | `true/false` | `9001` | N/A | N/A | 只返回匹配且有效的供应商 |
| all-只返回当前租户数据 | N/A | N/A | N/A | N/A | `9001/9002` | N/A | N/A | 仅返回 `9001` |
| get-按id获取成功 | N/A | N/A | 合法唯一 | N/A | `9001` | 存在 | N/A | 返回对象 |
| get-id不存在 | N/A | N/A | N/A | N/A | N/A | 不存在 | N/A | `not_exists_entity` |
| add-新增成功 | N/A | N/A | 合法唯一 | `true` | `9001` | N/A | N/A | 返回新增 id，数据落库 |
| add-名称重复失败 | N/A | N/A | 同租户重复 | `true` | `9001` | N/A | N/A | `exists_entity`，库内数量不变 |
| add-缺少名称校验失败 | N/A | N/A | 缺失 | N/A | N/A | N/A | N/A | `供应商名称必填` |
| add-名称超长校验失败 | N/A | N/A | 257 字符 | N/A | N/A | N/A | N/A | `供应商名称输入字符长度不能大于256个字符` |
| update-修改成功 | N/A | N/A | 合法唯一 | `false` | `9001` | 存在 | N/A | 返回成功且字段更新 |
| update-名称重复失败 | N/A | N/A | 同租户重复 | N/A | `9001` | 存在 | N/A | `exists_entity` |
| update-id不存在 | N/A | N/A | 合法唯一 | N/A | `9001` | 不存在 | N/A | `not_exists_entity` |
| delete-删除成功 | N/A | N/A | N/A | N/A | `9001` | 存在 | N/A | 删除成功且库内无记录 |
| delete-id不存在 | N/A | N/A | N/A | N/A | N/A | 不存在 | N/A | 删除失败 |
| excel-批量导入成功 | N/A | N/A | 全部唯一 | 默认 `true` | `9001` | N/A | 全部唯一 | 返回保存成功并落库 |
| excel-文件内重名失败 | N/A | N/A | 重复 | N/A | `9001` | N/A | 文件内重复 | 返回失败且不落库 |
| excel-与库内重名失败 | N/A | N/A | 与库内重复 | N/A | `9001` | N/A | 与库内重复 | 返回失败且原数据不变 |

## 覆盖性检查

- 所有控制器入口均至少一个成功路径。
- 所有显式失败路径均有覆盖：校验失败、同租户重名、id 不存在、excel 文件内重名、excel 库内重名。
- 所有关键分支均覆盖：
  - `pageSearch.searchObjects.Any()`：空 / 非空
  - `sqlTitle == "select"`：否 / 是
  - `is_valid == true`：否 / 是
  - `AnyAsync(...supplier_name...)`：否 / 是
  - `entity == null`：否 / 是
  - `ExecuteDeleteAsync() > 0`：否 / 是
  - `supplier_name_repeat_excel.Count > 0`：否 / 是
  - `supplier_name_repeat_exists.Count > 0`：否 / 是
