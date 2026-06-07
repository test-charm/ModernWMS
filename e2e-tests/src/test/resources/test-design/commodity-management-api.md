# 商品管理 API 测试设计

## 范围

- `POST /spu/list`
- `GET /spu?id={id}`
- `GET /spu/sku?sku_id={sku_id}`
- `GET /spu/sku-bar-code?bar_code={bar_code}`
- `POST /spu`
- `PUT /spu`
- `DELETE /spu?id={id}`
- `POST /spu/addlist`
- `PUT /spu/sku-safety-stock`

## 输入因子与取值

| 因子 | 说明 | 取值/等价类 | 备注 |
| --- | --- | --- | --- |
| 登录态 | 是否已登录 | 已登录 | `SpuController` 继承 `BaseController`，统一走 `@api-login-tenantId-9001` |
| 当前租户 | 当前用户 `tenant_id` | `9001` / 其他租户 `9002` | 列表过滤、重名校验、创建者、已知跨租户缺陷均依赖该因子 |
| `pageIndex/pageSize` | 分页开关 | `>0` / 任一 `<=0` | `PageAsync` 命中分页与全量两条路径 |
| 列表数据存在性 | 当前租户是否存在商品 | 有数据 / 无数据 | 覆盖列表成功空集与非空集 |
| `id` | 详情、修改、删除主键 | 存在 / 不存在 | 覆盖 `GET`、`PUT`、`DELETE` 的存在性分支 |
| `sku_id` | 规格详情主键 | 存在 / 不存在 | 覆盖 `/spu/sku` 成功与失败路径 |
| `bar_code` | 条码查询参数 | 合法存在 / 缺失 / 不存在 | 覆盖 `/spu/sku-bar-code` 校验、命中与未命中路径 |
| `spu_code` | 商品编码 | 合法唯一 / 同租户重复 / 其他租户同名 / 缺失 / 长度=32 / 长度=33 | `POST/PUT/addlist` 的核心判定因子 |
| `spu_name` | 商品名称 | 合法 / 缺失 / 长度=200 / 长度=201 | 影响校验与批量导入信息一致性 |
| `category_name` | 商品类别名称 | 合法存在 / 缺失 / 长度=32 / 长度=33 / 不存在 | 影响模型校验、列表展示、批量导入解析 |
| `supplier_name` | 供应商名称 | 合法存在 / 不存在 | 批量导入时必须能解析到当前租户供应商 |
| 明细 `detailList` | 规格明细列表 | 仅新增 / 新增+更新+删除 / 空列表 | 覆盖新增、修改、批量导入和安全库存更新的主分支 |
| 明细 `sku_code` | 规格编码 | 合法唯一 / 缺失 / 已存在 | 覆盖模型校验、导入追加规格、导入冲突 |
| 明细 `sku_name` / `unit` | 规格名称与单位 | 合法 / 缺失 | 覆盖嵌套校验 |
| 尺寸与单位 | `length_unit`、`volume_unit`、`weight_unit` 及长宽高重量 | 默认单位 / 非默认换算 | 覆盖体积重算逻辑 |
| 安全库存明细 | `detailList[].id` | 空列表 / `0` 新增 / `>0` 更新 / `<0` 删除 | 覆盖 `InsertOrUpdateSkuSafetyStockAsync` 成功与失败路径 |
| 关联仓库 | `warehouse_id` / `warehouse_name` | 已存在仓库 | 影响安全库存保存与响应明细 |
| 批量导入行集 | `/spu/addlist` 数组 | 空数组 / 全新商品 / 已有商品追加规格 / 文件内重复 SPU / 商品信息不一致 / 供应商缺失 / 类别缺失 / 规格编码冲突 / 请求内重复规格编码 | 覆盖批量导入主要成功/失败分支 |

## 输出因子

| 接口 | 关注输出 |
| --- | --- |
| `POST /spu/list` | `data.totals`、`data.rows[*]`、`detailList`、当前租户过滤 |
| `GET /spu?id` | 成功返回完整商品对象和规格列表；不存在返回 `code=400` |
| `GET /spu/sku` | 成功返回规格详情；不存在返回 `not_exists_entity` |
| `GET /spu/sku-bar-code` | 缺失条码返回 GET 参数校验错误；命中时返回规格详情；未命中返回 `not_exists_entity` |
| `POST /spu` | 成功返回新增 id；失败返回校验错误或 `exists_entity` |
| `PUT /spu` | 成功返回 `true`；失败返回 `exists_entity` 或 `not_exists_entity` |
| `DELETE /spu?id` | 成功返回 `删除成功`；不存在返回 `删除失败` |
| `POST /spu/addlist` | 成功返回受影响数量；失败返回 `batch_empty`、`batch_duplicate_spu_code`、`supplier_not_exists`、`category_not_exists`、`spu_info_inconsistent`、`sku_code_exists`、`duplicate_sku_in_batch` |
| `PUT /spu/sku-safety-stock` | 成功返回 `保存成功`，并反映到 `sku_safety_stock` 表；空明细时返回 `保存失败` |

## 流程图

```text
[进入商品管理 API]
  ├──→ {POST /spu/list}
  │      ├──→ {pageIndex/pageSize > 0} ──→ [按 create_time 倒序分页]
  │      └──→ {任一 <= 0} ──→ [返回全部当前租户数据]
  ├──→ {GET /spu?id}
  │      ├──→ {id 存在} ──→ [返回商品+规格]
  │      └──→ {id 不存在} ──→ [返回 not_exists_entity]
  ├──→ {GET /spu/sku}
  │      ├──→ {sku_id 存在} ──→ [返回规格详情]
  │      └──→ {sku_id 不存在} ──→ [返回 not_exists_entity]
  ├──→ {GET /spu/sku-bar-code}
  │      ├──→ {bar_code 缺失} ──→ [返回 GET 参数校验错误]
  │      ├──→ {bar_code 命中} ──→ [返回规格详情]
  │      └──→ {bar_code 不存在} ──→ [返回 not_exists_entity]
  ├──→ {POST /spu}
  │      ├──→ {模型校验失败} ──→ [返回 400 + 校验消息]
  │      ├──→ {同租户商品编码重复} ──→ [返回 exists_entity]
  │      └──→ [写入商品与规格，重算体积并返回新 id]
  ├──→ {PUT /spu}
  │      ├──→ {id 不存在} ──→ [返回 not_exists_entity]
  │      ├──→ {同租户商品编码重复} ──→ [返回 exists_entity]
  │      ├──→ {detail.id > 0} ──→ [更新已有规格]
  │      ├──→ {detail.id == 0} ──→ [新增规格]
  │      ├──→ {detail.id < 0} ──→ [删除规格]
  │      └──→ [重算全部规格体积并保存]
  ├──→ {DELETE /spu?id}
  │      ├──→ {删除条数 > 0} ──→ [先删 sku，再删 spu]
  │      └──→ [返回 delete_failed]
  ├──→ {POST /spu/addlist}
  │      ├──→ {空数组} ──→ [返回 batch_empty]
  │      ├──→ {文件内重复 SPU} ──→ [返回 batch_duplicate_spu_code]
  │      ├──→ {已有 SPU 但名称/供应商不一致} ──→ [返回 spu_info_inconsistent]
  │      ├──→ {供应商/类别不存在} ──→ [返回 not_exists]
  │      ├──→ {已有 SPU 且请求内规格编码重复} ──→ [返回 duplicate_sku_in_batch]
  │      ├──→ {已有 SPU 且规格编码冲突} ──→ [返回 sku_code_exists]
  │      └──→ [新增商品或给已有商品追加规格]
  └──→ {PUT /spu/sku-safety-stock}
         ├──→ {detailList 为空} ──→ [返回 save_failed]
         ├──→ {detail.id == 0} ──→ [新增安全库存]
         ├──→ {detail.id > 0} ──→ [更新安全库存]
         ├──→ {detail.id < 0} ──→ [删除安全库存]
         └──→ [保存成功]
```

## 用例矩阵

| 用例名 | `id/sku_id/bar_code` | `spu_code` | `spu_name` | `category_name` | 明细动作 | 批量导入形态 | 期望结果 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| list-返回当前租户商品与规格全部字段 | N/A | N/A | N/A | 合法存在 | 已有规格+安全库存 | N/A | 返回当前租户商品、规格及安全库存明细 |
| list-禁用分页返回全部当前租户商品 | N/A | N/A | N/A | 合法存在 | 无 | N/A | 任一分页参数 `<=0` 时返回全部当前租户数据 |
| list-无数据返回空数组 | N/A | N/A | N/A | N/A | 无 | N/A | `totals=0`、`rows=[]` |
| get-按id获取商品成功 | 存在 | N/A | N/A | 合法存在 | 已有规格 | N/A | 返回商品与规格明细 |
| get-id不存在失败 | 不存在 | N/A | N/A | N/A | 无 | N/A | 返回 `not_exists_entity` |
| get-sku-按sku_id获取成功 | 存在 `sku_id` | N/A | N/A | 合法存在 | 已有规格 | N/A | 返回规格详情 |
| get-sku-按sku_id获取失败 | 不存在 `sku_id` | N/A | N/A | N/A | 无 | N/A | 返回 `not_exists_entity` |
| get-sku-by-bar-code获取成功 | 存在 `bar_code` | N/A | N/A | 合法存在 | 已有规格 | N/A | 返回规格详情 |
| get-sku-by-bar-code不存在失败 | 不存在 `bar_code` | N/A | N/A | N/A | 无 | N/A | 返回 `not_exists_entity` |
| get-sku-by-bar-code缺少条码失败 | 缺失 `bar_code` | N/A | N/A | N/A | 无 | N/A | 返回 GET 参数校验错误 |
| add-新增商品成功并写入规格 | N/A | 合法唯一 | 合法 | 合法存在 | 新增规格 | N/A | 返回新 id，写入商品和规格，体积按单位换算计算 |
| add-同租户重复商品编码失败 | N/A | 同租户重复 | 合法 | 合法存在 | 新增规格 | N/A | 返回 `商品编码:{code} 已经存在` |
| add-其他租户同编码允许新增 | N/A | 其他租户已存在同码 | 合法 | 合法存在 | 新增规格 | N/A | 当前租户新增成功 |
| add-缺少核心必填字段失败 | N/A | 缺失 / 合法 | 缺失 / 合法 | 缺失 / 合法 | 新增规格 | N/A | 返回对应 `Required` 消息 |
| add-字段超长失败 | N/A | 长度 33 / 合法 | 长度 201 / 合法 | 长度 33 / 合法 | 新增规格 | N/A | 返回对应 `MaxLength` 消息 |
| update-成功更新商品并新增更新删除规格 | 存在 | 合法唯一 | 合法 | 合法存在 | `>0` 更新、`0` 新增、`<0` 删除 | N/A | 返回 `true`，规格与体积同步更新 |
| update-修改为同租户重复编码失败 | 存在 | 同租户重复 | 合法 | 合法存在 | 无 | N/A | 返回 `exists_entity` |
| update-允许与其他租户同编码 | 存在 | 其他租户已存在同码 | 合法 | 合法存在 | 无 | N/A | 当前租户修改成功 |
| update-id不存在失败 | 不存在 | 合法唯一 | 合法 | 合法存在 | 无 | N/A | 返回 `not_exists_entity` |
| delete-删除商品时同时删除规格 | 存在 | N/A | N/A | N/A | 删除商品全部规格 | N/A | `spu` 与 `sku` 均被删除 |
| delete-id不存在失败 | 不存在 | N/A | N/A | N/A | 无 | N/A | 返回 `删除失败` |
| addlist-批量导入新商品成功 | N/A | 全部唯一 | 合法 | 合法存在 | 每个商品新增规格 | 全新商品 | 返回受影响数量并落库 |
| addlist-给已有商品追加规格成功 | N/A | 已存在 | 与库一致 | 合法存在 | 新增规格 | 已有商品追加 | 返回新增规格数量，原商品更新时间变化 |
| addlist-空数组失败 | N/A | N/A | N/A | N/A | 无 | 空数组 | 返回 `批量数据为空` |
| addlist-文件内重复SPU失败 | N/A | 文件内重复 | 合法 | 合法存在 | 新增规格 | 文件内重复 SPU | 返回 `批量重复 SPU 代码` |
| addlist-商品信息不一致失败 | N/A | 已存在 | 与库不一致 | 合法存在 | 新增规格 | 已有商品信息不一致 | 返回 `请检查商品信息` |
| addlist-供应商不存在失败 | N/A | 合法唯一 | 合法 | 合法存在 | 新增规格 | 供应商缺失 | 返回 `供应商不存在` |
| addlist-商品分类不存在失败 | N/A | 合法唯一 | 合法 | 不存在 | 新增规格 | 类别缺失 | 返回 `商品分类不存在` |
| addlist-已有商品规格编码冲突失败 | N/A | 已存在 | 与库一致 | 合法存在 | 新增重复规格 | 规格编码冲突 | 返回 `规格编码已存在` |
| addlist-已有商品请求内规格编码重复失败 | N/A | 已存在 | 与库一致 | 合法存在 | 请求内重复规格 | 请求内重复规格编码 | 返回 `批量数据中存在重复的规格编码` |
| sku-safety-stock-新增更新删除成功 | 已存在 `sku_id` | N/A | N/A | N/A | `0/+/-` 三类明细 | N/A | `sku_safety_stock` 新增、更新、删除同时生效 |
| sku-safety-stock-空明细失败 | 已存在 `sku_id` | N/A | N/A | N/A | 空明细 | N/A | 返回 `保存失败` |

## 覆盖性检查

- 每个控制器入口至少一个稳定成功路径。
- 显式失败路径均有覆盖：模型校验失败、同租户 `spu_code` 重复、`id/sku_id` 不存在、缺失 `bar_code`、批量空数组、文件内重复 SPU、商品信息不一致、供应商不存在、已有规格编码冲突。
- 显式失败路径均有覆盖：模型校验失败、同租户 `spu_code` 重复、`id/sku_id` 不存在、缺失/不存在 `bar_code`、批量空数组、文件内重复 SPU、商品信息不一致、供应商不存在、类别不存在、已有商品请求内重复规格编码、已有规格编码冲突、安全库存空明细。
- 关键逻辑分支均有覆盖：
  - `pageIndex <= 0 || pageSize <= 0`：否 / 是
  - `GetAsync/GetSkuAsync/GetSkuByBarCodeAsync`：命中 / 未命中
  - `GetAsync/GetSkuAsync/GetSkuByBarCodeAsync`：命中 / 未命中
  - `string.IsNullOrEmpty(bar_code)`：否 / 是
  - `AnyAsync(...tenant_id && spu_code...)`：否 / 是 / 跨租户同码可通过
  - `detail.id > 0 / == 0 / < 0`：更新 / 新增 / 删除规格与安全库存
  - `detailList.Any()`（安全库存）：否 / 是
  - `viewModels == null || !viewModels.Any()`：否 / 是
  - `duplicateCodes.Any()`：否 / 是
  - `inconsistentCodes.Any()`：否 / 是
  - `existingSuppliers.TryGetValue(...)`：命中 / 未命中
  - `existingCategories.TryGetValue(...)`：命中 / 未命中
  - `duplicateSkuCodes.Any()`：否 / 是
  - `conflictSkuCodes.Any()`：否 / 是

## 测试数据策略

- 所有商品、规格、类别、供应商、仓库和安全库存数据均通过 JFactory 在场景内准备。
- 对 `spu`、`sku`、`sku_safety_stock`、`warehouse` 新增 JPA 实体与 Spec，避免依赖外部 SQL 脚本。
- 通过 `ApplicationSteps.clearDB()` 统一清理 `sku_safety_stock`、`sku`、`spu`、`category`、`supplier`、`warehouse` 等表，保证各场景自隔离。
- 创建、修改、导入成功用例尽量只显式设置当前断言需要的字段，其余依赖 Spec 默认值，减少脆弱性。

## 已知缺陷回归场景

- `commodity-management-known-bugs.feature` 记录当前高价值缺陷：
  1. `/spu/list` 返回的 `spu_description` 实际取自 `spu_code`，不是数据库里的商品描述。
  2. `GET /spu?id={id}` 未按当前租户过滤，可读取其他租户商品详情。
  3. `POST /spu` 新增商品时没有把按单位换算后的 `volume` 正确写回新建规格。
- 这些场景统一打 `@known-bug` 标签，默认不进入 `./gradlew cucumber` 回归。
- 单独复现时可执行：
  `./gradlew cucumber -Ptags='@known-bug' -Pfile=src/test/resources/features/commodity-management-known-bugs.feature`
