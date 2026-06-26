# language: zh-CN
@api-login-tenantId-9001
功能: 商品管理 API

  Rule: 列表 - POST /spu/list

    场景: 列表返回当前租户商品和规格全部字段
      假如存在"商品":
        """
        {
          spuCode: list-spu
          spuName: list-spu-name
          category.categoryName: list-category
          supplier.supplierName: list-supplier
          brand: list-brand
          origin: list-origin
          lengthUnit: 1
          volumeUnit: 0
          weightUnit: 1
          creator: user1
          createTime: '2024-01-03T00:00:00Z'
          lastUpdateTime: '2024-01-04T00:00:00Z'
          valid: true
          tenantId: 9001
          spuDescription: list-description
          skus: [{
            skuCode: list-sku
            skuName: list-sku-name
            barCode: list-bar
            imageUrl: '/img/list-sku.png'
            weight: 1
            lenght: 2
            width: 3
            height: 4
            volume: 24
            unit: EA
            cost: 5
            price: 6
            createTime: '2024-01-03T01:00:00Z'
            lastUpdateTime: '2024-01-04T01:00:00Z'
            skuSafetyStocks: [{
               warehouse.warehouseName: list-warehouse
               safetyStockQty: 8
            }]
          }]
        }
        """
      当POST "/spu/list":
        """
        {
          "pageIndex": 1,
          "pageSize": 20,
          "sqlTitle": "",
          "searchObjects": []
        }
        """
      那么response should be:
        """
        : {
          body.json= {
            isSuccess: true
            code: 200
            errorMessage: ""
            data= {
              totals: 1
              rows= [{
                id: 1
                spu_code: list-spu
                spu_name: list-spu-name
                category_id: 1
                category_name: list-category
                supplier_id: 1
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
                spu_description: list-spu     # bug: spu_description should be list-description
                detailList= [{
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
                  detailList= [{
                    id: 1
                    sku_id: 1
                    warehouse_id: 1
                    warehouse_name:list-warehouse
                    safety_stock_qty:8
                  }]
                }]
              }]
            }
          }
        }
        """

    场景: 禁用分页时返回全部当前商品
      假如存在"商品":
        | spuCode        | createTime           |
        | unpaged-oldest | 2024-01-01T00:00:00Z |
        | unpaged-middle | 2024-01-02T00:00:00Z |
        | unpaged-latest | 2024-01-03T00:00:00Z |
      当POST "商品查询请求" "/spu/list":
        """
        {
          pageIndex: 0
        }
        """
      那么response should be:
        """
        : {
          body.json.data: {
            totals: 3
            rows: | spu_code       | create_time         |
                  | unpaged-latest | 2024-01-03 00:00:00 |
                  | unpaged-middle | 2024-01-02 00:00:00 |
                  | unpaged-oldest | 2024-01-01 00:00:00 |
          }
        }
        """

    场景: 列表只返回当前租户商品
      假如存在"商品":
        | spuCode    | tenantId |
        | tenant-spu | 9001     |
        | other-spu  | 9002     |
      当POST "商品查询请求" "/spu/list":
        """
        {...}
        """
      那么response should be:
        """
        body.json.data.rows: | spu_code   |
                             | tenant-spu |
        """

    场景: 列表select模式只返回匹配的商品
      假如存在"商品":
        | spuCode      | tenantId |
        | select-spu-1 | 9001     |
        | select-spu-2 | 9001     |
        | other-spu    | 9001     |
      当POST "商品查询请求" "/spu/list":
        """
        {
          sqlTitle: select
          searchObjects: [{
            name: spu_code
            operator: 6
            text: select-spu
            value: select-spu
          }]
        }
        """
      那么response should be:
        """
        body.json.data.rows: | +spu_code     |
                             | select-spu-1  |
                             | select-spu-2  |
        """

    场景: 列表无数据时返回空数组
      当POST "商品查询请求" "/spu/list":
        """
        {...}
        """
      那么response should be:
        """
        : {
          body.json: {
            isSuccess: true
            code: 200
            errorMessage: ""
            data: {
              totals: 0
              rows: []
            }
          }
        }
        """

  Rule: 详情 - GET /spu?id={id}

    场景: 根据id获取商品成功并带规格明细
      假如存在"商品":
        """
        {
          spuCode: list-spu
          spuName: list-spu-name
          category.categoryName: list-category
          supplier.supplierName: list-supplier
          brand: list-brand
          origin: list-origin
          lengthUnit: 1
          volumeUnit: 0
          weightUnit: 1
          creator: user1
          createTime: '2024-01-03T00:00:00Z'
          lastUpdateTime: '2024-01-04T00:00:00Z'
          valid: true
          tenantId: 9001
          spuDescription: list-description
          skus: [{
            skuCode: list-sku
            skuName: list-sku-name
            barCode: list-bar
            imageUrl: '/img/list-sku.png'
            weight: 1
            lenght: 2
            width: 3
            height: 4
            volume: 24
            unit: EA
            cost: 5
            price: 6
            createTime: '2024-01-03T01:00:00Z'
            lastUpdateTime: '2024-01-04T01:00:00Z'
            skuSafetyStocks: [{
               warehouse.warehouseName: list-warehouse
               safetyStockQty: 8
            }]
          }]
        }
        """
      当GET "/spu?id=${商品.spuCode[list-spu].id}"
      那么response should be:
        """
        : {
          body.json= {
            isSuccess: true
            code: 200
            errorMessage: ""
            data= {
              id: 1
              spu_code: list-spu
              spu_name: list-spu-name
              category_id: 1
              category_name: list-category
              supplier_id: 1
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
              spu_description: list-description
              detailList= [{
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
                detailList= [{
                  id: 1
                  sku_id: 1
                  warehouse_id: 1
                  warehouse_name:list-warehouse
                  safety_stock_qty:8
                }]
              }]
              }
          }
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

  Rule: 规格详情 - GET /spu/sku

    场景: 根据sku_id获取规格详情成功
      假如存在"规格":
        """
        {
          skuCode: sku-one
          skuName: sku-one-name
          barCode: sku-bar
          imageUrl: '/img/sku-one.png'
          weight: 1
          lenght: 2
          width: 3
          height: 4
          volume: 24
          unit: EA
          cost: 5
          price: 6
          spu: {
            spuCode: sku-spu
            spuName: sku-spu-name
            category.categoryName: sku-category
            supplier.supplierName: sku-supplier
            brand: sku-brand
            origin: sku-origin
            lengthUnit: 1
            volumeUnit: 0
            weightUnit: 1
            spuDescription: sku-description
          }
        }
        """
      当GET "/spu/sku?sku_id=${规格.skuCode[sku-one].id}"
      那么response should be:
        """
        : {
          body.json= {
            isSuccess: true
            code: 200
            errorMessage: ""
            data= {
              spu_id: 1
              spu_code: sku-spu
              spu_name: sku-spu-name
              category_id: 1
              category_name: sku-category
              spu_description: sku-description
              supplier_id: 1
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
          }
        }
        """

    场景: 根据不存在的sku_id获取规格详情失败
      当GET "/spu/sku?sku_id=999"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "数据不存在或已被删除"
          data: null
        }
        """

  Rule: 规格详情 - GET /spu/sku-bar-code

    场景: 根据bar_code获取规格详情成功
      假如存在"规格":
        """
        {
          skuCode: barcode-sku
          skuName: barcode-sku-name
          barCode: barcode-only
          imageUrl: '/img/barcode-sku.png'
          weight: 1
          lenght: 2
          width: 3
          height: 4
          volume: 24
          unit: EA
          cost: 5
          price: 6
          spu: {
            spuCode: barcode-spu
            spuName: barcode-spu-name
            category.categoryName: barcode-category
            supplier.supplierName: barcode-supplier
            brand: barcode-brand
            origin: barcode-origin
            lengthUnit: 1
            volumeUnit: 0
            weightUnit: 1
            spuDescription: barcode-description
          }
        }
        """
      当GET "/spu/sku-bar-code?bar_code=barcode-only"
      那么response should be:
        """
        : {
          body.json: {
            isSuccess: true
            code: 200
            errorMessage: ""
            data= {
              spu_id: 1
              spu_code: barcode-spu
              spu_name: barcode-spu-name
              category_id: 1
              category_name: barcode-category
              spu_description: barcode-description
              supplier_id: 1
              supplier_name: barcode-supplier
              brand: barcode-brand
              origin: barcode-origin
              length_unit: 1
              volume_unit: 0
              weight_unit: 1
              sku_id: 1
              sku_code: barcode-sku
              sku_name: barcode-sku-name
              bar_code: barcode-only
              image_url: '/img/barcode-sku.png'
              weight: 1
              lenght: 2
              width: 3
              height: 4
              volume: 24
              unit: EA
              cost: 5
              price: 6
            }
          }
        }
        """

    场景: 根据不存在的bar_code获取规格详情失败
      当GET "/spu/sku-bar-code?bar_code=missing-bar-code"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "数据不存在或已被删除"
          data: null
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
      假如存在:
        """
        商品类别: | categoryName    |
                 | create-category |

        供应商: | supplierName    |
               | create-supplier |

        仓库: | warehouseName    |
             | create-warehouse |
        """
      当POST "/spu":
        """
        {
          "spu_code": "create-spu",
          "spu_name": "create-spu-name",
          "category_id": ${商品类别.categoryName[create-category].id},
          "category_name": "create-category",
          "supplier_id": ${供应商.supplierName[create-supplier].id},
          "supplier_name": "create-supplier",
          "brand": "create-brand",
          "origin": "create-origin",
          "length_unit": 2,
          "volume_unit": 0,
          "weight_unit": 1,
          "spu_description": "create-description",
          "detailList": [{
            "sku_code": "create-sku",
            "sku_name": "create-sku-name",
            "bar_code": "create-bar",
            "image_url": "/img/create-sku.png",
            "unit": "BOX",
            "weight": 1,
            "lenght": 1,
            "width": 2,
            "height": 3,
            "cost": 5,
            "price": 6,
            "detailList": [{
              "warehouse_id": ${仓库.warehouseName[create-warehouse].id},
              "warehouse_name": "create-warehouse",
              "safety_stock_qty": 10
            }]
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
          supplier.supplierName: create-supplier
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
          skus= [{
            id: 1
            skuCode: create-sku
            skuName: create-sku-name
            barCode: create-bar
            imageUrl: '/img/create-sku.png'
            weight: 1
            lenght: 1
            width: 2
            height: 3
            volume: 0
            unit: BOX
            cost: 5
            price: 6,
            <<createTime,lastUpdateTime>> is AlmostNow
            spu.spuCode: create-spu
            skuSafetyStocks= [{
              id: 1
              sku.skuCode: create-sku
              warehouse.warehouseName: create-warehouse
              safetyStockQty: 10
            }]
          }]
        }
        """

    场景: 新增同租户重复商品编码失败且不会重复落库
      假如存在"商品":
        | spuCode       |
        | duplicate-spu |
      当POST "商品创建请求" "/spu":
        """
        {
          spuCode: duplicate-spu
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
        商品: | spuCode       |
             | duplicate-spu |
        """

    场景: 新增商品允许与其他租户商品编码同名
      假如存在"商品":
        | spuCode          | tenantId |
        | cross-tenant-spu | 9002     |
      当POST "依赖已存在的 商品创建请求" "/spu":
        """
        {
          spuCode: cross-tenant-spu
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
        商品: | spuCode          | +tenantId |
             | cross-tenant-spu | 9001      |
             | cross-tenant-spu | 9002      |
        """

    场景大纲: 新增商品缺少字段时校验失败
      当POST "商品创建请求" "/spu":
        """
        {
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
        | spuCode      | 商品编码必填       |
        | spuName      | 商品名称必填       |
        | categoryName | 商品类别必填       |

    场景大纲: 新增商品字段超长时校验失败
      当POST "商品创建请求" "/spu":
        """
        {
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
        | fieldName    | maxLength | errorMessage         |
        | spuCode      | 32        | 商品编码输入字符长度不能大于32个字符  |
        | spuName      | 200       | 商品名称输入字符长度不能大于200个字符 |
        | categoryName | 32        | 商品类别输入字符长度不能大于32个字符  |

    场景大纲: 新增商品规格缺少字段时校验失败
      当POST "依赖已存在的 商品创建请求" "/spu":
        """
        {
          detailList: [{
            <fieldName>: null
          }]
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
        | fieldName | errorMessage |
        | skuCode   | 规格编码必填       |
        | skuName   | 规格名称必填       |

    场景大纲: 新增商品规格字段超长时校验失败
      当POST "依赖已存在的 商品创建请求" "/spu":
        """
        {
          detailList: [{
            <fieldName>: 'A'*(<maxLength>+1)
          }]
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
        | fieldName | maxLength | errorMessage         |
        | skuCode   | 32        | 规格编码输入字符长度不能大于32个字符  |
        | skuName   | 200       | 规格名称输入字符长度不能大于200个字符 |
        | barCode   | 64        | 商品条码输入字符长度不能大于64个字符  |

    场景大纲: 新增商品规格安全缺少字段时校验失败
      当POST "依赖已存在的 商品创建请求" "/spu":
        """
        {
          detailList: [{
              detailList: [{
              <fieldName>: null
              }]
          }]
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
        | fieldName     | errorMessage |
        | warehouseName | 仓库名称必填       |

  Rule: 修改 - PUT /spu

    场景: 修改商品成功 - 无规格
      假如存在:
        """
        商品: {
          spuCode: list-spu
          spuName: list-spu-name
          category.categoryName: list-category
          supplier.supplierName: list-supplier
          brand: list-brand
          origin: list-origin
          lengthUnit: 1
          volumeUnit: 0
          weightUnit: 1
          creator: user1
          createTime: '2024-01-03T00:00:00Z'
          lastUpdateTime: '2024-01-04T00:00:00Z'
          valid: true
          spuDescription: list-description
        }

        商品类别: | categoryName       |
                 | update-category    |

        供应商: | supplierName       |
               | update-supplier    |
        """
      当PUT "/spu":
        """
        {
          "id": ${商品.spuCode[list-spu].id},
          "spu_code": "update-spu-new",
          "spu_name": "update-spu-name-new",
          "category_id": ${商品类别.categoryName[update-category].id},
          "category_name": "update-category",
          "supplier_id": ${供应商.supplierName[update-supplier].id},
          "supplier_name": "update-supplier",
          "brand": "update-brand-new",
          "origin": "update-origin-new",
          "length_unit": 2,
          "volume_unit": 0,
          "weight_unit": 2,
          "spu_description": "update-description-new",
          "is_valid": false
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
          supplier.supplierName: update-supplier
          supplierName: update-supplier
          brand: update-brand-new
          origin: update-origin-new
          lengthUnit: 2
          volumeUnit: 0
          weightUnit: 2
          valid: false
          creator: user1
          createTime: '2024-01-03T00:00:00Z'
          lastUpdateTime is AlmostNow
        }
        """

    场景: 修改商品成功 - 添加规格
      假如存在:
        """
        商品: {
          spuCode: list-spu
          skus: []
        }
        """
      当PUT "商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[list-spu].id}
          spuCode: list-spu
          detailList: [{
            id: 0
            skuCode: add-sku-3
            skuName: add-sku-name-3
            barCode: add-bar-3
            imageUrl: imageUrl3
            unit: EA
            weight: 1
            lenght: 1
            width: 1
            height: 1
            cost: 2
            price: 3
          }]
        }
        """
      那么response should be:
        """
        body.json.code: 200
        """
      并且数据应为:
        """
        商品: {
          skus= [{
            id: {...}
            skuCode: add-sku-3
            skuName: add-sku-name-3
            barCode: add-bar-3
            imageUrl: imageUrl3
            unit: EA
            weight: 1
            lenght: 1
            width: 1
            height: 1
            cost: 2
            price: 3
            volume: 1,          # 计算值，需要写专门的测试
            <<createTime, lastUpdateTime>> is AlmostNow
            spu.spuCode: list-spu
            skuSafetyStocks: []
          }]
        }
        """

    场景: 修改商品成功 - 修改规格
      假如存在:
        """
        商品: {
          spuCode: list-spu
          skus: [{
            skuCode: add-sku-3
            skuName: add-sku-name-3
            barCode: add-bar-3
            imageUrl: imageUrl3
            unit: EA
            weight: 1
            lenght: 1
            width: 1
            height: 1
            cost: 2
            price: 3
            createTime: '2024-01-03T01:00:00Z'
          }]
        }
        """
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[list-spu].id}
          spuCode: list-spu
          detailList: [{
            id: 1
            skuCode: update-sku-3
            skuName: update-sku-name-3
            barCode: update-bar-3
            imageUrl: update-imageUrl3
            unit: ABC
            weight: 2
            lenght: 2
            width: 2
            height: 2
            cost: 3
            price: 4
          }]
        }
        """
      那么response should be:
        """
        body.json.code: 200
        """
      并且数据应为:
        """
        商品: {
          skus= [{
            id: {...}
            skuCode: update-sku-3
            skuName: update-sku-name-3
            barCode: update-bar-3
            imageUrl: update-imageUrl3
            unit: ABC
            weight: 2
            lenght: 2
            width: 2
            height: 2
            cost: 3
            price: 4
            volume: 8,          # 计算值，需要写专门的测试
            createTime: '2024-01-03T01:00:00Z'
            lastUpdateTime is AlmostNow
            spu.spuCode: list-spu
            skuSafetyStocks: []
          }]
        }
        """

    场景: 修改商品成功 - 删除规格
      假如存在:
        """
        商品: {
          spuCode: list-spu
          skus: [{ ... }]
        }
        """
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[list-spu].id}
          spuCode: list-spu
          detailList: [{
            id: -1
          }]
        }
        """
      那么response should be:
        """
        body.json.code: 200
        """
      并且数据应为:
        """
        商品: {
          skus= []
        }
        """

    场景: 修改商品为同租户重复编码失败
      假如存在"商品":
        | spuCode                |
        | update-duplicate-src   |
        | update-duplicate-other |
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[update-duplicate-src].id}
          spuCode: update-duplicate-other
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
        | spuCode             | tenantId |
        | update-cross-source | 9001     |
        | update-cross-target | 9002     |
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: ${商品.spuCode[update-cross-source].id}
          spuCode: update-cross-target
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

    场景大纲: 修改商品缺少字段时校验失败
      当PUT "商品修改请求" "/spu":
        """
        {
          id: 1
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
        | spuCode      | 商品编码必填       |
        | spuName      | 商品名称必填       |
        | categoryName | 商品类别必填       |

    场景大纲: 修改商品字段超长时校验失败
      当PUT "商品修改请求" "/spu":
        """
        {
          id: 1
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
        | fieldName    | maxLength | errorMessage         |
        | spuCode      | 32        | 商品编码输入字符长度不能大于32个字符  |
        | spuName      | 200       | 商品名称输入字符长度不能大于200个字符 |
        | categoryName | 32        | 商品类别输入字符长度不能大于32个字符  |

    场景大纲: 修改商品规格缺少字段时校验失败
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: 1
          detailList: [{
            <fieldName>: null
          }]
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
        | fieldName | errorMessage |
        | skuCode   | 规格编码必填       |
        | skuName   | 规格名称必填       |

    场景大纲: 修改商品规格字段超长时校验失败
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: 1
          detailList: [{
            <fieldName>: 'A'*(<maxLength>+1)
          }]
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
        | fieldName | maxLength | errorMessage         |
        | skuCode   | 32        | 规格编码输入字符长度不能大于32个字符  |
        | skuName   | 200       | 规格名称输入字符长度不能大于200个字符 |
        | barCode   | 64        | 商品条码输入字符长度不能大于64个字符  |

    场景大纲: 修改商品规格安全库存缺少字段时校验失败
      当PUT "依赖已存在的 商品修改请求" "/spu":
        """
        {
          id: 1
          detailList: [{
              detailList: [{
              <fieldName>: null
              }]
          }]
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
        | fieldName     | errorMessage |
        | warehouseName | 仓库名称必填       |

  Rule: 删除 - DELETE /spu?id={id}

    场景: 删除商品成功并同时删除规格
      假如存在"商品":
        | spuCode    | spuName     | category.categoryName |
        | delete-spu | delete-name | delete-category       |
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
        | categoryName    |
        | import-category |
      假如存在"供应商":
        | supplierName    |
        | import-supplier |
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
          supplier.supplierName: import-supplier
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
        | categoryName    |
        | append-category |
      假如存在"供应商":
        | supplierName    |
        | append-supplier |
      假如存在"商品":
        | spuCode    | spuName     | category.categoryName | supplier.supplierName | createTime           | lastUpdateTime       |
        | append-spu | append-name | append-category       | append-supplier       | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z |
      假如存在"规格":
        | spu.spuCode | skuCode             | skuName              | unit |
        | append-spu  | append-existing-sku | append-existing-name | EA   |
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
        | categoryName       |
        | duplicate-category |
      假如存在"供应商":
        | supplierName       |
        | duplicate-supplier |
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
        | categoryName          |
        | inconsistent-category |
      假如存在"供应商":
        | supplierName          |
        | inconsistent-supplier |
        | changed-supplier      |
      假如存在"商品":
        | spuCode          | spuName           | category.categoryName | supplier.supplierName |
        | inconsistent-spu | inconsistent-name | inconsistent-category | inconsistent-supplier |
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
        | categoryName              |
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

    场景: 批量导入时商品分类不存在失败
      假如存在"供应商":
        | supplierName              |
        | missing-category-supplier |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: missing-category-spu
          spuName: missing-category-name
          categoryName: missing-category
          supplierName: missing-category-supplier
          detailList: [{
            skuCode: missing-category-sku
            skuName: missing-category-sku-name
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品分类不存在"
          data: 0
        }
        """

    场景: 批量导入已有商品时规格编码冲突失败
      假如存在"商品类别":
        | categoryName      |
        | conflict-category |
      假如存在"供应商":
        | supplierName      |
        | conflict-supplier |
      假如存在"商品":
        | spuCode      | spuName       | category.categoryName | supplier.supplierName |
        | conflict-spu | conflict-name | conflict-category     | conflict-supplier     |
      假如存在"规格":
        | spu.spuCode  | skuCode      | skuName      | unit |
        | conflict-spu | conflict-sku | conflict-sku | EA   |
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

    场景: 批量导入已有商品时请求内规格编码重复失败
      假如存在"商品类别":
        | categoryName           |
        | duplicate-sku-category |
      假如存在"供应商":
        | supplierName           |
        | duplicate-sku-supplier |
      假如存在"商品":
        | spuCode           | spuName            | category.categoryName  | supplier.supplierName  |
        | duplicate-sku-spu | duplicate-sku-name | duplicate-sku-category | duplicate-sku-supplier |
      当POST "商品导入请求[]" "/spu/addlist":
        """
        [{
          spuCode: duplicate-sku-spu
          spuName: duplicate-sku-name
          categoryName: duplicate-sku-category
          supplierName: duplicate-sku-supplier
          detailList: [{
            skuCode: duplicate-sku-code
            skuName: duplicate-sku-name-1
            unit: EA
          } {
            skuCode: duplicate-sku-code
            skuName: duplicate-sku-name-2
            unit: EA
          }]
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "批量数据中存在重复的规格编码"
          data: 0
        }
        """
      并且数据应为:
        """
        规格= []
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
        | stock-sku   | stock-wh-1              | 6              |
        | stock-sku   | stock-wh-2              | 9              |
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

    场景: 安全库存明细为空时保存失败
      假如存在"商品":
        | spuCode         | spuName         | category.categoryName |
        | empty-stock-spu | empty-stock-spu | empty-stock-category  |
      假如存在"规格":
        | spu.spuCode     | skuCode         | skuName         | unit |
        | empty-stock-spu | empty-stock-sku | empty-stock-sku | EA   |
      当PUT "安全库存修改请求" "/spu/sku-safety-stock":
        """
        {
          skuId: ${规格.skuCode[empty-stock-sku].id}
          detailList: []
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "保存失败"
          data: null
        }
        """
