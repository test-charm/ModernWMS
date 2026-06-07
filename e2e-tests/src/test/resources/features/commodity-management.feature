# language: zh-CN
@api-login-tenantId-9001
功能: 商品管理 API

  Rule: 列表 - POST /spu/list

    场景: 列表返回当前租户商品和规格全部字段
      假如存在"商品":
        | spuCode    | spuName       | category.categoryName | supplierId | supplierName  | brand      | origin      | lengthUnit | volumeUnit | weightUnit | creator | createTime           | lastUpdateTime       | valid | tenantId | spuDescription     |
        | list-spu   | list-spu-name | list-category         | 11         | list-supplier | list-brand | list-origin | 1          | 0          | 1          | user1   | 2024-01-03T00:00:00Z | 2024-01-04T00:00:00Z | true  | 9001     | list-description   |
        | hidden-spu | hidden-name   | hidden-category       | 22         | hidden-supply | hidden-brand | hidden-origin | 1        | 0          | 1          | user2   | 2024-01-03T00:00:00Z | 2024-01-04T00:00:00Z | true  | 9002     | hidden-description |
      假如存在"规格":
        | spu.spuCode | skuCode  | skuName       | barCode  | imageUrl          | weight | lenght | width | height | volume | unit | cost | price | createTime           | lastUpdateTime       |
        | list-spu    | list-sku | list-sku-name | list-bar | /img/list-sku.png | 1      | 2      | 3     | 4      | 24     | EA   | 5    | 6     | 2024-01-03T01:00:00Z | 2024-01-04T01:00:00Z |
      假如存在"规格安全库存":
        | sku.skuCode | warehouse.warehouseName | safetyStockQty |
        | list-sku    | list-warehouse          | 8              |
      当POST "商品查询请求" "/spu/list":
        """
        {
          pageIndex: 1
          pageSize: 20
          sqlTitle: ''
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
        }
        """
      并且response should be:
        """
        body.json.data.totals: 1
        """
      并且response should be:
        """
        body.json.data.rows.size: 1
        """
      并且response should be:
        """
        body.json.data.rows[0]: {
          id: 1
          spu_code: list-spu
          spu_name: list-spu-name
          category_id: 1
          category_name: list-category
          supplier_id: 11
          supplier_name: list-supplier
          brand: list-brand
          origin: list-origin
          length_unit: 1
          volume_unit: 0
          weight_unit: 1
          creator: user1
          create_time: '2024-01-03 00:00:00'
          last_update_time: '2024-01-04 00:00:00'
          is_valid: true
        }
        """
      并且response should be:
        """
        body.json.data.rows[0].detailList.size: 1
        """
      并且response should be:
        """
        body.json.data.rows[0].detailList[0]: {
          id: 1
          spu_id: 1
          sku_code: list-sku
          sku_name: list-sku-name
          bar_code: list-bar
          image_url: '/img/list-sku.png'
          weight: 1
          lenght: 2
          width: 3
          height: 4
          volume: 24
          unit: EA
          cost: 5
          price: 6
          create_time: '2024-01-03 01:00:00'
          last_update_time: '2024-01-04 01:00:00'
        }
        """
      并且response should be:
        """
        body.json.data.rows[0].detailList[0].detailList.size: 1
        """
      并且response should be:
        """
        body.json.data.rows[0].detailList[0].detailList[0]= {
          id: 1
          sku_id: 1
          warehouse_id: 1
          warehouse_name: list-warehouse
          safety_stock_qty: 8
        }
        """

    场景: 禁用分页时返回全部当前租户商品
      假如存在"商品":
        | spuCode        | spuName        | category.categoryName | supplierId | supplierName | createTime           | lastUpdateTime       | tenantId |
        | unpaged-oldest | unpaged-oldest | unpaged-category      | 11         | supply-a     | 2024-01-01T00:00:00Z | 2024-01-01T00:00:00Z | 9001     |
        | unpaged-middle | unpaged-middle | unpaged-category      | 11         | supply-a     | 2024-01-02T00:00:00Z | 2024-01-02T00:00:00Z | 9001     |
        | unpaged-latest | unpaged-latest | unpaged-category      | 11         | supply-a     | 2024-01-03T00:00:00Z | 2024-01-03T00:00:00Z | 9001     |
        | hidden-spu     | hidden-spu     | hidden-category       | 11         | supply-a     | 2024-01-04T00:00:00Z | 2024-01-04T00:00:00Z | 9002     |
      当POST "商品查询请求" "/spu/list":
        """
        {
          pageIndex: 0
        }
        """
      那么response should be:
        """
        body.json.data.totals: 3
        """
      并且response should be:
        """
        body.json.data.rows.size: 3
        """
      并且response should be:
        """
        body.json.data.rows[0].spu_code: unpaged-latest
        """
      并且response should be:
        """
        body.json.data.rows[1].spu_code: unpaged-middle
        """
      并且response should be:
        """
        body.json.data.rows[2].spu_code: unpaged-oldest
        """

    场景: 列表无数据时返回空数组
      当POST "商品查询请求" "/spu/list":
        """
        {
          pageIndex: 1
          pageSize: 20
          sqlTitle: ''
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
        }
        """
      并且response should be:
        """
        body.json.data.totals: 0
        """
      并且response should be:
        """
        body.json.data.rows.size: 0
        """

  Rule: 详情 - GET /spu?id={id}

    场景: 根据id获取商品成功并带规格明细
      假如存在"商品":
        | spuCode | spuName      | category.categoryName | supplierId | supplierName | brand    | origin    | lengthUnit | volumeUnit | weightUnit | creator | createTime           | lastUpdateTime       | valid | spuDescription |
        | get-spu | get-spu-name | get-category          | 11         | get-supplier | get-brand | get-origin | 1         | 0          | 1          | user1   | 2024-01-03T00:00:00Z | 2024-01-04T00:00:00Z | true  | get-description |
      假如存在"规格":
        | spu.spuCode | skuCode | skuName      | barCode | weight | lenght | width | height | volume | unit | cost | price |
        | get-spu     | get-sku | get-sku-name | get-bar | 1      | 2      | 3     | 4      | 24     | EA   | 5    | 6     |
      当GET "/spu?id=${商品.spuCode[get-spu].id}"
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
        }
        """
      并且response should be:
        """
        body.json.data: {
          id: 1
          spu_code: get-spu
          spu_name: get-spu-name
          category_id: 1
          category_name: get-category
          spu_description: get-description
          supplier_id: 11
          supplier_name: get-supplier
          brand: get-brand
          origin: get-origin
          length_unit: 1
          volume_unit: 0
          weight_unit: 1
          creator: user1
          create_time: '2024-01-03 00:00:00'
          last_update_time: '2024-01-04 00:00:00'
          is_valid: true
        }
        """
      并且response should be:
        """
        body.json.data.detailList.size: 1
        """
      并且response should be:
        """
        body.json.data.detailList[0]: {
          id: 1
          spu_id: 1
          sku_code: get-sku
          sku_name: get-sku-name
          bar_code: get-bar
          weight: 1
          lenght: 2
          width: 3
          height: 4
          volume: 24
          unit: EA
          cost: 5
          price: 6
        }
        """

    场景: 根据不存在的id获取商品失败
      当GET "/spu?id=999"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "数据不存在或已被删除"
          data: null
        }
        """

  Rule: 规格详情 - GET /spu/sku 与 GET /spu/sku-bar-code

    场景: 根据sku_id获取规格详情成功
      假如存在"商品":
        | spuCode | spuName      | category.categoryName | supplierId | supplierName | brand    | origin    | lengthUnit | volumeUnit | weightUnit | spuDescription |
        | sku-spu | sku-spu-name | sku-category          | 11         | sku-supplier | sku-brand | sku-origin | 1         | 0          | 1          | sku-description |
      假如存在"规格":
        | spu.spuCode | skuCode | skuName      | barCode | imageUrl         | weight | lenght | width | height | volume | unit | cost | price |
        | sku-spu     | sku-one | sku-one-name | sku-bar | /img/sku-one.png | 1      | 2      | 3     | 4      | 24     | EA   | 5    | 6     |
      当GET "/spu/sku?sku_id=${规格.skuCode[sku-one].id}"
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
        }
        """
      并且response should be:
        """
        body.json.data= {
          spu_id: 1
          spu_code: sku-spu
          spu_name: sku-spu-name
          category_id: 1
          category_name: sku-category
          spu_description: sku-description
          supplier_id: 11
          supplier_name: sku-supplier
          brand: sku-brand
          origin: sku-origin
          length_unit: 1
          volume_unit: 0
          weight_unit: 1
          sku_id: 1
          sku_code: sku-one
          sku_name: sku-one-name
          bar_code: sku-bar
          image_url: '/img/sku-one.png'
          weight: 1
          lenght: 2
          width: 3
          height: 4
          volume: 24
          unit: EA
          cost: 5
          price: 6
        }
        """

    场景: 根据bar_code获取规格详情成功
      假如存在"商品":
        | spuCode     | spuName          | category.categoryName | supplierId | supplierName      | brand      | origin      | lengthUnit | volumeUnit | weightUnit | spuDescription     |
        | barcode-spu | barcode-spu-name | barcode-category      | 11         | barcode-supplier  | barcode-brand | barcode-origin | 1       | 0          | 1          | barcode-description |
      假如存在"规格":
        | spu.spuCode  | skuCode     | skuName          | barCode      | weight | lenght | width | height | volume | unit | cost | price |
        | barcode-spu  | barcode-sku | barcode-sku-name | barcode-only | 1      | 2      | 3     | 4      | 24     | EA   | 5    | 6     |
      当GET "/spu/sku-bar-code?bar_code=barcode-only"
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
        }
        """
      并且response should be:
        """
        body.json.data: {
          spu_id: 1
          spu_code: barcode-spu
          spu_name: barcode-spu-name
          category_name: barcode-category
          spu_description: barcode-description
          supplier_name: barcode-supplier
          sku_id: 1
          sku_code: barcode-sku
          sku_name: barcode-sku-name
          bar_code: barcode-only
          unit: EA
        }
        """

    场景: 缺少bar_code时校验失败
      当GET "/spu/sku-bar-code"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "parameter value“”does not pass the verification！"
          data: null
        }
        """

  Rule: 新增 - POST /spu

    场景: 新增商品成功并写入商品和规格
      假如存在"商品类别":
        | categoryName    |
        | create-category |
      假如存在"供应商":
        | supplierName    |
        | create-supplier |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: create-spu
          spuName: create-spu-name
          categoryId: ${商品类别.categoryName[create-category].id}
          categoryName: create-category
          supplierId: ${供应商.supplierName[create-supplier].id}
          supplierName: create-supplier
          brand: create-brand
          origin: create-origin
          lengthUnit: 2
          volumeUnit: 0
          weightUnit: 1
          spuDescription: create-description
          detailList: [{
            skuCode: create-sku
            skuName: create-sku-name
            barCode: create-bar
            unit: BOX
            weight: 1
            lenght: 1
            width: 2
            height: 3
            cost: 5
            price: 6
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
        商品= {
          id: 1
          spuCode: create-spu
          spuName: create-spu-name
          category.categoryName: create-category
          spuDescription: create-description
          supplierId: 1
          supplierName: create-supplier
          brand: create-brand
          origin: create-origin
          lengthUnit: 2
          volumeUnit: 0
          weightUnit: 1
          creator: e2e-login-hook-user
          tenantId: 9001
          valid: true,
          <<createTime,lastUpdateTime>> is AlmostNow
        }
        """
      并且数据应为:
        """
        规格: {
          id: 1
          spu.spuCode: create-spu
          skuCode: create-sku
          skuName: create-sku-name
          barCode: create-bar
          unit: BOX
          weight: 1
          lenght: 1
          width: 2
          height: 3
          cost: 5
          price: 6,
          <<createTime,lastUpdateTime>> is AlmostNow
        }
        """

    场景: 新增同租户重复商品编码失败且不会重复落库
      假如存在"商品":
        | spuCode       | spuName       | category.categoryName |
        | duplicate-spu | duplicate-old | duplicate-category    |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: duplicate-spu
          spuName: duplicate-new
          categoryId: 1
          categoryName: duplicate-category
          detailList: [{
            skuCode: duplicate-sku
            skuName: duplicate-sku-name
            unit: EA
          }]
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品编码:duplicate-spu 已经存在"
          data: 0
        }
        """
      并且数据应为:
        """
        商品: | spuCode       | spuName       |
             | duplicate-spu | duplicate-old |
        """

    场景: 新增商品允许与其他租户商品编码同名
      假如存在"商品类别":
        | categoryName           |
        | cross-tenant-category  |
      假如存在"商品":
        | spuCode          | spuName          | category.categoryName | tenantId |
        | cross-tenant-spu | cross-tenant-old | hidden-category       | 9002     |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: cross-tenant-spu
          spuName: cross-tenant-new
          categoryId: ${商品类别.categoryName[cross-tenant-category].id}
          categoryName: cross-tenant-category
          detailList: [{
            skuCode: cross-tenant-sku
            skuName: cross-tenant-sku-name
            unit: EA
          }]
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: 2
        }
        """
      并且数据应为:
        """
        商品: | spuCode          | spuName          | +tenantId |
             | cross-tenant-spu | cross-tenant-new | 9001      |
             | cross-tenant-spu | cross-tenant-old | 9002      |
        """

    场景大纲: 新增商品缺少核心必填字段时校验失败
      假如存在"商品类别":
        | categoryName           |
        | required-test-category |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: required-spu
          spuName: required-name
          categoryId: ${商品类别.categoryName[required-test-category].id}
          categoryName: required-test-category
          detailList: [{
            skuCode: required-sku
            skuName: required-sku-name
            unit: EA
          }]
          <fieldName>: null
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: false
          code: 400
          errorMessage: "<errorMessage>"
        }
        """
      例子:
        | fieldName    | errorMessage |
        | spuCode      | 商品编码必填 |
        | spuName      | 商品名称必填 |
        | categoryName | 商品类别必填 |

    场景大纲: 新增商品字段超长时校验失败
      假如存在"商品类别":
        | categoryName        |
        | maxlength-category  |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: maxlength-spu
          spuName: maxlength-name
          categoryId: ${商品类别.categoryName[maxlength-category].id}
          categoryName: maxlength-category
          detailList: [{
            skuCode: maxlength-sku
            skuName: maxlength-sku-name
            unit: EA
          }]
          <fieldName>: 'A'*(<maxLength>+1)
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: false
          code: 400
          errorMessage: "<errorMessage>"
        }
        """
      例子:
        | fieldName    | maxLength | errorMessage |
        | spuCode      | 32        | 商品编码输入字符长度不能大于32个字符 |
        | spuName      | 200       | 商品名称输入字符长度不能大于200个字符 |
        | categoryName | 32        | 商品类别输入字符长度不能大于32个字符 |

    场景: 新增商品规格缺少编码时校验失败
      假如存在"商品类别":
        | categoryName     |
        | detail-category  |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: detail-spu
          spuName: detail-name
          categoryId: ${商品类别.categoryName[detail-category].id}
          categoryName: detail-category
          detailList: [{
            skuCode: null
            skuName: detail-sku-name
            unit: EA
          }]
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: false
          code: 400
          errorMessage: "规格编码必填"
        }
        """

  Rule: 修改 - PUT /spu

    场景: 修改商品成功并同步新增更新删除规格
      假如存在"商品类别":
        | categoryName     |
        | update-category  |
      假如存在"供应商":
        | supplierName     |
        | update-supplier  |
      假如存在"商品":
        | spuCode    | spuName         | category.categoryName | supplierId | supplierName   | brand      | origin      | lengthUnit | volumeUnit | weightUnit | creator     | createTime           | lastUpdateTime       | spuDescription     |
        | update-spu | update-spu-name | update-category       | 1          | update-supplier | old-brand | old-origin  | 1          | 0          | 1          | origin-user | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | old-description    |
      假如存在"规格":
        | spu.spuCode | skuCode      | skuName          | barCode      | unit | weight | lenght | width | height | volume | cost | price | createTime           | lastUpdateTime       |
        | update-spu  | update-sku-1 | update-sku-name1 | update-bar-1 | EA   | 1      | 1      | 1     | 1      | 1      | 2    | 3     | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z |
        | update-spu  | delete-sku-2 | delete-sku-name2 | delete-bar-2 | EA   | 1      | 1      | 1     | 1      | 1      | 2    | 3     | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z |
      当PUT "商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[update-spu].id}
          spuCode: update-spu-new
          spuName: update-spu-name-new
          categoryId: ${商品类别.categoryName[update-category].id}
          categoryName: update-category
          supplierId: ${供应商.supplierName[update-supplier].id}
          supplierName: update-supplier
          brand: update-brand-new
          origin: update-origin-new
          lengthUnit: 2
          volumeUnit: 0
          weightUnit: 2
          spuDescription: update-description-new
          detailList: [{
            id: ${规格.skuCode[update-sku-1].id}
            skuCode: update-sku-1-new
            skuName: update-sku-name-1-new
            barCode: update-bar-1-new
            unit: BOX
            weight: 2
            lenght: 1
            width: 2
            height: 4
            cost: 7
            price: 8
          } {
            id: 0
            skuCode: add-sku-3
            skuName: add-sku-name-3
            barCode: add-bar-3
            unit: EA
            weight: 1
            lenght: 1
            width: 1
            height: 1
            cost: 2
            price: 3
          } {
            id: -2
            skuCode: delete-sku-2
            skuName: delete-sku-name2
            barCode: delete-bar-2
            unit: EA
          }]
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: true
        }
        """
      并且数据应为:
        """
        商品: {
          id: 1
          spuCode: update-spu-new
          spuName: update-spu-name-new
          category.categoryName: update-category
          spuDescription: update-description-new
          supplierId: 1
          supplierName: update-supplier
          brand: update-brand-new
          origin: update-origin-new
          lengthUnit: 2
          volumeUnit: 0
          weightUnit: 2
          creator: origin-user
          createTime: '2024-01-01T00:00:00Z',
          lastUpdateTime is AlmostNow
        }
        """
      并且数据应为:
        """
        规格: | spu.spuCode     | skuCode          | skuName                | barCode          | unit | volume | cost | price |
             | update-spu-new   | update-sku-1-new | update-sku-name-1-new  | update-bar-1-new | BOX  | 8000   | 7    | 8     |
             | update-spu-new   | add-sku-3        | add-sku-name-3         | add-bar-3        | EA   | 1000   | 2    | 3     |
        """

    场景: 修改商品为同租户重复编码失败
      假如存在"商品":
        | spuCode                | spuName                | category.categoryName |
        | update-duplicate-src   | update-duplicate-src   | duplicate-category    |
        | update-duplicate-other | update-duplicate-other | duplicate-category    |
      当PUT "商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[update-duplicate-src].id}
          spuCode: update-duplicate-other
          spuName: update-duplicate-src
          categoryId: 1
          categoryName: duplicate-category
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品编码:update-duplicate-other 已经存在"
          data: false
        }
        """
      并且数据应为:
        """
        商品: | spuCode                |
             | update-duplicate-src   |
             | update-duplicate-other |
        """

    场景: 修改商品允许与其他租户同编码
      假如存在"商品":
        | spuCode             | spuName             | category.categoryName | tenantId |
        | update-cross-source | update-cross-source | update-cross-category | 9001     |
        | update-cross-target | update-cross-target | other-category        | 9002     |
      当PUT "商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[update-cross-source].id}
          spuCode: update-cross-target
          spuName: update-cross-source
          categoryId: 1
          categoryName: update-cross-category
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: true
        }
        """
      并且数据应为:
        """
        商品: | spuCode             | +tenantId |
             | update-cross-target | 9001      |
             | update-cross-target | 9002      |
        """

    场景: 修改不存在的商品失败
      当PUT "商品修改请求" "/spu":
        """
        {
          id: 999
          spuCode: missing-spu
          spuName: missing-name
          categoryName: missing-category
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "数据不存在或已被删除"
          data: false
        }
        """

  Rule: 删除 - DELETE /spu?id={id}

    场景: 删除商品成功并同时删除规格
      假如存在"商品":
        | spuCode     | spuName      | category.categoryName |
        | delete-spu  | delete-name  | delete-category       |
      假如存在"规格":
        | spu.spuCode | skuCode      | skuName       | unit |
        | delete-spu  | delete-sku-1 | delete-name-1 | EA   |
        | delete-spu  | delete-sku-2 | delete-name-2 | EA   |
      当DELETE "/spu?id=${商品.spuCode[delete-spu].id}"
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: "删除成功"
        }
        """
      并且数据应为:
        """
        商品= []
        """
      并且数据应为:
        """
        规格= []
        """

    场景: 删除不存在的商品失败
      当DELETE "/spu?id=999"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "删除失败"
          data: null
        }
        """

  Rule: 批量导入 - POST /spu/addlist

    场景: 批量导入新商品成功
      假如存在"商品类别":
        | categoryName     |
        | import-category  |
      假如存在"供应商":
        | supplierName     |
        | import-supplier  |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: import-spu
          spuName: import-spu-name
          categoryName: import-category
          supplierName: import-supplier
          brand: import-brand
          lengthUnit: 1
          volumeUnit: 0
          weightUnit: 1
          detailList: [{
            skuCode: import-sku
            skuName: import-sku-name
            barCode: import-bar
            unit: EA
            weight: 1
            lenght: 2
            width: 3
            height: 4
            cost: 5
            price: 6
          }]
        }]
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
        商品: {
          spuCode: import-spu
          spuName: import-spu-name
          category.categoryName: import-category
          supplierId: 1
          supplierName: import-supplier
          brand: import-brand
          creator: e2e-login-hook-user
          tenantId: 9001,
          <<createTime,lastUpdateTime>> is AlmostNow
        }
        """
      并且数据应为:
        """
        规格: {
          spu.spuCode: import-spu
          skuCode: import-sku
          skuName: import-sku-name
          barCode: import-bar
          unit: EA
          volume: 24
        }
        """

    场景: 批量导入到已存在商品时追加新规格
      假如存在"商品类别":
        | categoryName     |
        | append-category  |
      假如存在"供应商":
        | supplierName     |
        | append-supplier  |
      假如存在"商品":
        | spuCode    | spuName    | category.categoryName | supplierId | supplierName   | createTime           | lastUpdateTime       |
        | append-spu | append-name | append-category      | 1          | append-supplier | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z |
      假如存在"规格":
        | spu.spuCode | skuCode             | skuName               | unit |
        | append-spu  | append-existing-sku | append-existing-name  | EA   |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: append-spu
          spuName: append-name
          categoryName: append-category
          supplierName: append-supplier
          detailList: [{
            skuCode: append-new-sku
            skuName: append-new-name
            unit: EA
          }]
        }]
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
        商品: {
          spuCode: append-spu
          spuName: append-name,
          lastUpdateTime is AlmostNow
        }
        """
      并且数据应为:
        """
        规格: | spu.spuCode | skuCode             | skuName              |
             | append-spu  | append-existing-sku | append-existing-name |
             | append-spu  | append-new-sku      | append-new-name      |
        """

    场景: 批量导入空数组失败
      当POST "/spu/addlist":
        """
        []
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "批量数据为空"
          data: 0
        }
        """

    场景: 批量导入时文件内重复SPU编码失败
      假如存在"商品类别":
        | categoryName        |
        | duplicate-category  |
      假如存在"供应商":
        | supplierName        |
        | duplicate-supplier  |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: duplicate-in-file
          spuName: duplicate-in-file-a
          categoryName: duplicate-category
          supplierName: duplicate-supplier
          detailList: [{
            skuCode: duplicate-sku-a
            skuName: duplicate-sku-a
            unit: EA
          }]
        } {
          spuCode: duplicate-in-file
          spuName: duplicate-in-file-b
          categoryName: duplicate-category
          supplierName: duplicate-supplier
          detailList: [{
            skuCode: duplicate-sku-b
            skuName: duplicate-sku-b
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "批量重复 SPU 代码"
          data: 0
        }
        """
      并且数据应为:
        """
        商品= []
        """
      并且数据应为:
        """
        规格= []
        """

    场景: 批量导入已有商品但商品信息不一致时失败
      假如存在"商品类别":
        | categoryName            |
        | inconsistent-category   |
      假如存在"供应商":
        | supplierName            |
        | inconsistent-supplier   |
        | changed-supplier        |
      假如存在"商品":
        | spuCode           | spuName           | category.categoryName | supplierId | supplierName          |
        | inconsistent-spu  | inconsistent-name | inconsistent-category | 1          | inconsistent-supplier |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: inconsistent-spu
          spuName: changed-name
          categoryName: inconsistent-category
          supplierName: inconsistent-supplier
          detailList: [{
            skuCode: inconsistent-sku
            skuName: inconsistent-sku-name
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "请检查商品信息"
          data: 0
        }
        """
      并且数据应为:
        """
        商品: {
          spuCode: inconsistent-spu
          spuName: inconsistent-name
          supplierName: inconsistent-supplier
        }
        """
      并且数据应为:
        """
        规格= []
        """

    场景: 批量导入时供应商不存在失败
      假如存在"商品类别":
        | categoryName             |
        | missing-supplier-category |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: missing-supplier-spu
          spuName: missing-supplier-name
          categoryName: missing-supplier-category
          supplierName: missing-supplier
          detailList: [{
            skuCode: missing-supplier-sku
            skuName: missing-supplier-sku-name
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "供应商不存在"
          data: 0
        }
        """

    场景: 批量导入已有商品时规格编码冲突失败
      假如存在"商品类别":
        | categoryName        |
        | conflict-category   |
      假如存在"供应商":
        | supplierName        |
        | conflict-supplier   |
      假如存在"商品":
        | spuCode        | spuName        | category.categoryName | supplierId | supplierName      |
        | conflict-spu   | conflict-name  | conflict-category     | 1          | conflict-supplier |
      假如存在"规格":
        | spu.spuCode  | skuCode        | skuName        | unit |
        | conflict-spu | conflict-sku   | conflict-sku   | EA   |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: conflict-spu
          spuName: conflict-name
          categoryName: conflict-category
          supplierName: conflict-supplier
          detailList: [{
            skuCode: conflict-sku
            skuName: conflict-new-sku
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "规格编码已存在"
          data: 0
        }
        """
      并且数据应为:
        """
        规格: | spu.spuCode  | skuCode      |
             | conflict-spu | conflict-sku |
        """

  Rule: 规格安全库存 - PUT /spu/sku-safety-stock

    场景: 新增修改删除安全库存成功
      假如存在"商品":
        | spuCode   | spuName   | category.categoryName |
        | stock-spu | stock-spu | stock-category        |
      假如存在"规格":
        | spu.spuCode | skuCode   | skuName   | unit |
        | stock-spu   | stock-sku | stock-sku | EA   |
      假如存在"规格安全库存":
        | sku.skuCode | warehouse.warehouseName | safetyStockQty |
        | stock-sku   | stock-wh-1             | 6              |
        | stock-sku   | stock-wh-2             | 9              |
      假如存在"仓库":
        | warehouseName |
        | stock-wh-3    |
      当PUT "安全库存修改请求" "/spu/sku-safety-stock":
        """
        {
          skuId: ${规格.skuCode[stock-sku].id}
          detailList: [{
            id: 1
            skuId: ${规格.skuCode[stock-sku].id}
            warehouseId: 1
            warehouseName: stock-wh-1
            safetyStockQty: 20
          } {
            id: -2
            skuId: ${规格.skuCode[stock-sku].id}
            warehouseId: 2
            warehouseName: stock-wh-2
            safetyStockQty: 9
          } {
            id: 0
            skuId: ${规格.skuCode[stock-sku].id}
            warehouseId: ${仓库.warehouseName[stock-wh-3].id}
            warehouseName: stock-wh-3
            safetyStockQty: 30
          }]
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: "保存成功"
        }
        """
      并且数据应为:
        """
        规格安全库存: | sku.skuCode | warehouse.warehouseName | safetyStockQty |
                     | stock-sku   | stock-wh-1              | 20             |
                     | stock-sku   | stock-wh-3              | 30             |
        """
