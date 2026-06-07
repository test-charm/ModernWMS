# language: zh-CN
@known-bug @api-login-tenantId-9001
功能: 商品管理 API 已知缺陷

  # 这些场景用于记录当前已知缺陷。
  # 默认回归通过 build.gradle 中的 `not @known-bug` 标签过滤排除。

  场景: 列表应返回数据库里的商品描述
    # 当前实际行为：/spu/list 把 spu_code 填到了 spu_description 字段。
    # 正确行为：应返回数据库中的 spu_description，供前端列表正确展示商品描述。
    假如存在"商品":
      | spuCode      | spuName      | category.categoryName | spuDescription      |
      | bug-list-spu | bug-list-spu | bug-list-category     | expected-description |
    当POST "商品查询请求" "/spu/list":
      """
      {
      }
      """
    那么response should be:
      """
      body.json.data.rows[0].spu_description: expected-description
      """

  场景: 其他租户商品详情不应被当前租户读取
    # 当前实际行为：GET /spu?id={id} 未按 tenant_id 过滤，能直接读到其他租户商品。
    # 正确行为：应返回 not_exists_entity，避免跨租户数据泄漏。
    假如存在"商品":
      | spuCode         | spuName         | category.categoryName | tenantId |
      | cross-tenant-spu | cross-tenant-spu | cross-tenant-category | 9002     |
    当GET "/spu?id=${商品.spuCode[cross-tenant-spu].id}"
    那么response should be:
      """
      body.json= {
        isSuccess: false
        code: 400
        errorMessage: "数据不存在或已被删除"
        data: null
      }
      """

  场景: 新增商品时应按单位换算重算规格体积
    # 当前实际行为：POST /spu 在把 viewModel 映射成实体之后才修改 detailList.volume，
    # 导致新增规格写入的 volume 不是按单位换算后的结果。
    假如存在"商品类别":
      | categoryName          |
      | volume-bug-category   |
    当POST "商品创建请求" "/spu":
      """
      {
        spuCode: volume-bug-spu
        spuName: volume-bug-name
        categoryId: ${商品类别.categoryName[volume-bug-category].id}
        categoryName: volume-bug-category
        lengthUnit: 2
        volumeUnit: 0
        detailList: [{
          skuCode: volume-bug-sku
          skuName: volume-bug-sku-name
          unit: BOX
          lenght: 1
          width: 2
          height: 3
        }]
      }
      """
    那么response should be:
      """
      body.json= {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: 1
      }
      """
    并且数据应为:
      """
      规格: {
        spu.spuCode: volume-bug-spu
        skuCode: volume-bug-sku
        volume: 6000
      }
      """
