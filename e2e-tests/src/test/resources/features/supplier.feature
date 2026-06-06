# language: zh-CN
@api-login-tenantId-9001
功能: 供应商信息 API

  Rule: 列表 - POST /supplier/list

    场景: 列表返回的全部字段
      假如存在"供应商":
        | supplierName         | city | address | email  | manager  | contactTel  | creator | createTime           | lastUpdateTime       | valid | tenantId |
        | list-active-supplier | c1   | addr1   | email1 | manager1 | 13800000000 | user1   | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  | 9001     |
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
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= {
            totals: 1
            rows= | id | supplier_name          | tenant_id | city | address | email  | manager  | contact_tel   | creator | create_time           | last_update_time       | is_valid |
                  | 1  | list-active-supplier   | 9001      | c1   | addr1 | email1  | manager1 | '13800000000'  | user1   | '2024-01-01 00:00:00' | '2024-01-02 00:00:00' | true      |
          }
        }
        """

    场景: 列表仅返回当前租户的数据
      假如存在"供应商":
        | supplierName               | tenantId |
        | list-active-supplier       | 9001     |
        | list-other-tenant-supplier | 9002     |
      当POST "供应商查询请求" "/supplier/list":
        """
        {}
        """
      那么response should be:
        """
        body.json.data.rows: | supplier_name          |
                             | list-active-supplier   |
        """

    场景: 列表返回valid和invalid数据，如果不提供查询条件
      假如存在"供应商":
        | supplierName           | valid |
        | list-active-supplier   | true  |
        | list-inactive-supplier | false |
      当POST "供应商查询请求" "/supplier/list":
        """
        {
          sqlTitle: ''
        }
        """
      那么response should be:
        """
        body.json.data.rows: | supplier_name          |
                             | list-inactive-supplier |
                             | list-active-supplier   |
        """

#    场景: 列表select模式只返回有效的供应商
#      假如存在"供应商":
#        | supplierName          | valid |
#        | select-match-active   | true  |
#        | select-match-inactive | false |
#      当POST "供应商查询请求" "/supplier/list":
#        """
#        {
#          sqlTitle: 'select'
#          searchObjects: [{
#            name: supplier_name
#            operator: 6
#            text: select-match
#            value: select-match
#          }]
#        }
#        """
#      那么response should be:
#        """
#        body.json.data.rows: | supplier_name          |
#                             | select-match-active    |
#        """

    场景: 列表select模式只返回匹配且有效的供应商
      假如存在"供应商":
        | supplierName          | valid | tenantId | createTime           |
        | select-match-active   | true  | 9001     | 2024-01-03T00:00:00Z |
        | select-match-inactive | false | 9001     | 2024-01-02T00:00:00Z |
        | select-other-active   | true  | 9001     | 2024-01-01T00:00:00Z |
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
          isSuccess: true
          code: 200
          errorMessage: ""
          data: {
            totals: 1
            rows: [
              {
                supplier_name: "select-match-active"
                is_valid: true
                tenant_id: 9001
              }
            ]
          }
        }
        """

    场景: 禁用分页时列表返回全部当前租户数据
      假如存在"供应商":
        | supplierName         | tenantId | createTime           |
        | unpaged-oldest       | 9001     | 2024-01-01T00:00:00Z |
        | unpaged-middle       | 9001     | 2024-01-02T00:00:00Z |
        | unpaged-latest       | 9001     | 2024-01-03T00:00:00Z |
        | unpaged-other-tenant | 9002     | 2024-01-04T00:00:00Z |
      当POST "/supplier/list":
        """
        {
          "pageIndex": 0,
          "pageSize": 2,
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
            totals: 3
            rows: [
              { supplier_name: "unpaged-latest" }
              { supplier_name: "unpaged-middle" }
              { supplier_name: "unpaged-oldest" }
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

    场景: 获取全部供应商在无数据时返回空数组
      当GET "/supplier/all"
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: []
        }
        """

    场景: 根据id获取供应商成功
      假如存在"供应商":
        | supplierName   | city   | address     | manager | email            | contactTel  |
        | get-supplier-1 | Suzhou | Supplier Rd | Alice   | get1@example.com | 13800000001 |
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='create-supplier'
        and .city='Shanghai'
        and .address='Create Road'
        and .email='create@example.com'
        and .manager='Bob'
        and .contactTel='13800000002'
        and .creator='e2e-login-hook-user'
        and .valid=true
        and .tenantId=9001L
        """

    场景: 新增同租户重名供应商失败且不会重复落库
      假如存在"供应商":
        | supplierName       |
        | duplicate-supplier |
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='duplicate-supplier'
        and .tenantId=9001L
        and .creator='e2e-supplier'
        """

    场景: 新增供应商允许与其他租户同名
      假如存在"供应商":
        | supplierName          | tenantId |
        | cross-tenant-add-name | 9002     |
      当POST "/supplier":
        """
        {
          "supplier_name": "cross-tenant-add-name",
          "city": "Shanghai",
          "address": "Cross Tenant Create Road",
          "email": "cross-tenant-add@example.com",
          "manager": "Bob",
          "contact_tel": "13800000015",
          "is_valid": true
        }
        """
      那么response should be:
        """
        body.json: {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: 2
        }
        """
    并且 "供应商.id[1]"应为:
    """
        .supplierName='cross-tenant-add-name'
        and .tenantId=9002L
        and .creator='e2e-supplier'
        """
    并且 "供应商.id[2]"应为:
    """
        .supplierName='cross-tenant-add-name'
        and .city='Shanghai'
        and .address='Cross Tenant Create Road'
        and .email='cross-tenant-add@example.com'
        and .manager='Bob'
        and .contactTel='13800000015'
        and .creator='e2e-login-hook-user'
        and .valid=true
        and .tenantId=9001L
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
        | supplierName    | city    | address     | manager | email           | contactTel  | valid |
        | update-supplier | Nanjing | Old Address | Carol   | old@example.com | 13800000006 | true  |
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='update-supplier-renamed'
        and .city='Hangzhou'
        and .address='New Address'
        and .email='new@example.com'
        and .manager='David'
        and .contactTel='13800000007'
        and .creator='e2e-supplier'
        and .valid=false
        and .tenantId=9001L
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
        .supplierName='update-duplicate-target'
        and .tenantId=9001L
        """

    场景: 修改供应商允许与其他租户同名
      假如存在"供应商":
        | supplierName               | tenantId |
        | update-cross-tenant-source | 9001     |
        | update-cross-tenant-target | 9002     |
      当PUT "/supplier":
        """
        {
          "id": 1,
          "supplier_name": "update-cross-tenant-target",
          "city": "Hangzhou",
          "address": "Cross Tenant Update Address",
          "email": "cross-tenant-update@example.com",
          "manager": "David",
          "contact_tel": "13800000016",
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='update-cross-tenant-target'
        and .city='Hangzhou'
        and .address='Cross Tenant Update Address'
        and .email='cross-tenant-update@example.com'
        and .manager='David'
        and .contactTel='13800000016'
        and .tenantId=9001L
        and .valid=false
        """
    并且 "供应商.id[2]"应为:
    """
        .supplierName='update-cross-tenant-target'
        and .tenantId=9002L
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
        | supplierName    |
        | delete-supplier |
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='excel-supplier-1'
        and .city='Wuxi'
        and .address='Excel Road 1'
        and .email='excel1@example.com'
        and .manager='Eva'
        and .contactTel='13800000010'
        and .creator='e2e-login-hook-user'
        and .valid=true
        and .tenantId=9001L
        """
    并且 "供应商.id[2]"应为:
    """
        .supplierName='excel-supplier-2'
        and .city='Wuxi'
        and .address='Excel Road 2'
        and .email='excel2@example.com'
        and .manager='Frank'
        and .contactTel='13800000011'
        and .creator='e2e-login-hook-user'
        and .valid=true
        and .tenantId=9001L
        """

    场景: Excel批量导入允许与其他租户同名
      假如存在"供应商":
        | supplierName            | tenantId |
        | excel-cross-tenant-name | 9002     |
      当POST "/supplier/excel":
        """
        [
          {
            "supplier_name": "excel-cross-tenant-name",
            "city": "Wuxi",
            "address": "Excel Cross Tenant Road",
            "email": "excel-cross-tenant@example.com",
            "manager": "Grace",
            "contact_tel": "13800000017"
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
    并且 "供应商.id[1]"应为:
    """
        .supplierName='excel-cross-tenant-name'
        and .tenantId=9002L
        and .creator='e2e-supplier'
        """
    并且 "供应商.id[2]"应为:
    """
        .supplierName='excel-cross-tenant-name'
        and .city='Wuxi'
        and .address='Excel Cross Tenant Road'
        and .email='excel-cross-tenant@example.com'
        and .manager='Grace'
        and .contactTel='13800000017'
        and .creator='e2e-login-hook-user'
        and .valid=true
        and .tenantId=9001L
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
        | supplierName             |
        | excel-duplicate-existing |
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
