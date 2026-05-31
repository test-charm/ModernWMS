# language: zh-CN
@api-login
功能: 供应商信息 API

  场景: 列表返回当前租户全部供应商并包含无效数据
    假如存在"供应商":
      | supplierName              | valid | tenantId | createTime           |
      | list-active-supplier      | true  | 9001     | 2024-01-02T00:00:00 |
      | list-inactive-supplier    | false | 9001     | 2024-01-01T00:00:00 |
      | list-other-tenant-supplier| true  | 9002     | 2024-01-03T00:00:00 |
    当POST "/supplier/list":
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
      body.json: {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: {
          totals: 2
          rows: [
            { supplier_name: "list-active-supplier" }
            { supplier_name: "list-inactive-supplier" }
          ]
        }
      }
      """

  场景: 列表select模式只返回匹配且有效的供应商
    假如存在"供应商":
      | supplierName               | valid | tenantId | createTime           |
      | select-match-active       | true  | 9001     | 2024-01-03T00:00:00 |
      | select-match-inactive     | false | 9001     | 2024-01-02T00:00:00 |
      | select-other-active       | true  | 9001     | 2024-01-01T00:00:00 |
    当POST "/supplier/list":
      """
      {
        "pageIndex": 1,
        "pageSize": 20,
        "sqlTitle": "select",
        "searchObjects": [
          {
            "name": "supplier_name",
            "operator": 6,
            "text": "select-match",
            "value": "select-match"
          }
        ]
      }
      """
    那么response should be:
      """
      body.json: {
        data: {
          totals: 1
          rows: [
            { supplier_name: "select-match-active" }
          ]
        }
      }
      """

  场景: 获取全部供应商时只返回当前租户数据
    假如存在"供应商":
      | supplierName          | tenantId |
      | tenant-current-only   | 9001     |
      | tenant-foreign-hidden | 9002     |
    当GET "/supplier/all"
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        data: [
          { supplier_name: "tenant-current-only" }
        ]
      }
      """

  场景: 根据id获取供应商成功
    假如存在"供应商":
      | supplierName    | city    | address      | manager | email                | contactTel   |
      | get-supplier-1  | Suzhou  | Supplier Rd  | Alice   | get1@example.com     | 13800000001  |
    当GET "/supplier?id=1"
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        data: {
          id: 1
          supplier_name: "get-supplier-1"
          city: "Suzhou"
          address: "Supplier Rd"
          manager: "Alice"
          email: "get1@example.com"
          contact_tel: "13800000001"
          is_valid: true
          tenant_id: 9001
        }
      }
      """

  场景: 根据不存在的id获取供应商失败
    当GET "/supplier?id=999"
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
        errorMessage: "数据不存在或已被删除"
      }
      """

  场景: 新增供应商成功并写入数据库
    当POST "/supplier":
      """
      {
        "supplier_name": "create-supplier",
        "city": "Shanghai",
        "address": "Create Road",
        "email": "create@example.com",
        "manager": "Bob",
        "contact_tel": "13800000002",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: 1
      }
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      supplierName = "create-supplier"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      city = "Shanghai"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      address = "Create Road"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      email = "create@example.com"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      manager = "Bob"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      contactTel = "13800000002"
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      valid = true
      """
    并且 "供应商.supplierName[create-supplier]"应为:
      """
      tenantId = 9001L
      """

  场景: 新增同租户重名供应商失败且不会重复落库
    假如存在"供应商":
      | supplierName        |
      | duplicate-supplier  |
    当POST "/supplier":
      """
      {
        "supplier_name": "duplicate-supplier",
        "city": "Shanghai",
        "address": "Duplicate Road",
        "email": "duplicate@example.com",
        "manager": "Bob",
        "contact_tel": "13800000003",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
        errorMessage: "供应商名称:duplicate-supplier 已经存在"
        data: 0
      }
      """
    并且 所有"供应商"应为:
      """
      size= 1
      """

  场景: 新增供应商缺少名称时校验失败
    当POST "/supplier":
      """
      {
        "city": "Shanghai",
        "address": "No Name Road",
        "email": "noname@example.com",
        "manager": "Bob",
        "contact_tel": "13800000004",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        code: 400
        errorMessage: "供应商名称必填"
      }
      """

  场景: 新增供应商名称超长时校验失败
    当POST "/supplier":
      """
      {
        "supplier_name": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "city": "Shanghai",
        "address": "Too Long Road",
        "email": "toolong@example.com",
        "manager": "Bob",
        "contact_tel": "13800000005",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        code: 400
        errorMessage: "供应商名称输入字符长度不能大于256个字符"
      }
      """

  场景: 修改供应商成功
    假如存在"供应商":
      | supplierName      | city   | address        | manager | email               | contactTel   | valid |
      | update-supplier   | Nanjing| Old Address    | Carol   | old@example.com     | 13800000006  | true  |
    当PUT "/supplier":
      """
      {
        "id": 1,
        "supplier_name": "update-supplier-renamed",
        "city": "Hangzhou",
        "address": "New Address",
        "email": "new@example.com",
        "manager": "David",
        "contact_tel": "13800000007",
        "is_valid": false
      }
      """
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: true
      }
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      supplierName = "update-supplier-renamed"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      id = 1
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      city = "Hangzhou"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      address = "New Address"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      email = "new@example.com"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      manager = "David"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      contactTel = "13800000007"
      """
    并且 "供应商.supplierName[update-supplier-renamed]"应为:
      """
      valid = false
      """

  场景: 修改供应商为同租户重复名称失败
    假如存在"供应商":
      | supplierName              |
      | update-duplicate-target   |
      | update-duplicate-existing |
    当PUT "/supplier":
      """
      {
        "id": 1,
        "supplier_name": "update-duplicate-existing",
        "city": "Hangzhou",
        "address": "Duplicate Update Address",
        "email": "duplicate-update@example.com",
        "manager": "David",
        "contact_tel": "13800000008",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
        errorMessage: "供应商名称:update-duplicate-existing 已经存在"
        data: false
      }
      """
    并且 "供应商.id[1]"应为:
      """
      supplierName = "update-duplicate-target"
      """

  场景: 修改不存在的供应商失败
    当PUT "/supplier":
      """
      {
        "id": 999,
        "supplier_name": "missing-update-supplier",
        "city": "Hangzhou",
        "address": "Missing Address",
        "email": "missing-update@example.com",
        "manager": "David",
        "contact_tel": "13800000009",
        "is_valid": true
      }
      """
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
        errorMessage: "数据不存在或已被删除"
        data: false
      }
      """

  场景: 删除供应商成功
    假如存在"供应商":
      | supplierName      |
      | delete-supplier   |
    当DELETE "/supplier?id=1"
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: "删除成功"
      }
      """
    并且 所有"供应商"应为:
      """
      size= 0
      """

  场景: 删除不存在的供应商失败
    当DELETE "/supplier?id=999"
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
        errorMessage: "删除失败"
      }
      """

  场景: Excel批量导入供应商成功
    当POST "/supplier/excel":
      """
      [
        {
          "supplier_name": "excel-supplier-1",
          "city": "Wuxi",
          "address": "Excel Road 1",
          "email": "excel1@example.com",
          "manager": "Eva",
          "contact_tel": "13800000010"
        },
        {
          "supplier_name": "excel-supplier-2",
          "city": "Wuxi",
          "address": "Excel Road 2",
          "email": "excel2@example.com",
          "manager": "Frank",
          "contact_tel": "13800000011"
        }
      ]
      """
    那么response should be:
      """
      body.json: {
        isSuccess: true
        code: 200
        errorMessage: ""
        data: "保存成功"
      }
      """
    并且 所有"供应商"应为:
      """
      size= 2
      """

  场景: Excel批量导入时文件内重名失败
    当POST "/supplier/excel":
      """
      [
        {
          "supplier_name": "excel-duplicate-in-payload",
          "city": "Wuxi",
          "address": "Excel Payload Road 1",
          "email": "payload1@example.com",
          "manager": "Eva",
          "contact_tel": "13800000012"
        },
        {
          "supplier_name": "excel-duplicate-in-payload",
          "city": "Wuxi",
          "address": "Excel Payload Road 2",
          "email": "payload2@example.com",
          "manager": "Frank",
          "contact_tel": "13800000013"
        }
      ]
      """
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
      }
      """
    并且 所有"供应商"应为:
      """
      size= 0
      """

  场景: Excel批量导入时与库内重名失败
    假如存在"供应商":
      | supplierName               |
      | excel-duplicate-existing   |
    当POST "/supplier/excel":
      """
      [
        {
          "supplier_name": "excel-duplicate-existing",
          "city": "Wuxi",
          "address": "Excel Existing Road",
          "email": "existing@example.com",
          "manager": "Eva",
          "contact_tel": "13800000014"
        }
      ]
      """
    那么response should be:
      """
      body.json: {
        isSuccess: false
        code: 400
      }
      """
    并且 所有"供应商"应为:
      """
      size= 1
      """
