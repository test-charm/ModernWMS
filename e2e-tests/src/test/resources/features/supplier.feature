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
        {...}
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

    场景: 列表select模式只返回有效的供应商
      假如存在"供应商":
        | supplierName          | valid |
        | select-match-active   | true  |
        | select-match-inactive | false |
      当POST "供应商查询请求" "/supplier/list":
        """
        {
          sqlTitle: 'select'
          searchObjects: [{
            name: supplier_name
            operator: 6
            text: select-match
            value: select-match
          }]
        }
        """
      那么response should be:
        """
        body.json.data.rows: | supplier_name          |
                             | select-match-active    |
        """

    场景: 列表select模式只返回匹配且有效的供应商
      假如存在"供应商":
        | supplierName        | valid |
        | select-match-active | true  |
        | select-other-active | true  |
      当POST "供应商查询请求" "/supplier/list":
        """
        {
          sqlTitle: select
          searchObjects: [{
            name: supplier_name
            operator: 6
            text: select-match
            value: select-match
          }]
        }
        """
      那么response should be:
        """
        body.json.data.rows: | supplier_name          |
                             | select-match-active    |
        """

    场景大纲: 禁用分页时列表返回全部当前租户数据
      假如存在"供应商":
        | supplierName   |
        | unpaged-oldest |
        | unpaged-middle |
        | unpaged-latest |
      当POST "供应商查询请求" "/supplier/list":
        """
        {
          pageIndex: <pageIndex>
          pageSize: <pageSize>
        }
        """
      那么response should be:
        """
        body.json.data.rows: | supplier_name          |
                             | unpaged-latest         |
                             | unpaged-middle         |
                             | unpaged-oldest         |
        """
      例子:
        | pageIndex | pageSize |
        | 0         | 2        |
        | 2         | 0        |
        | -1        | 2        |
        | 2         | -1       |

  Rule: 全列表 - GET  /supplier/all

    场景: 全列表返回的全部字段
      假如存在"供应商":
        | supplierName         | city | address | email  | manager  | contactTel  | creator | createTime           | lastUpdateTime       | valid | tenantId |
        | list-active-supplier | c1   | addr1   | email1 | manager1 | 13800000000 | user1   | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  | 9001     |
      那么"/supplier/all" should response:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= | id | supplier_name          | tenant_id | city | address | email  | manager  | contact_tel   | creator | create_time           | last_update_time       | is_valid |
                | 1  | list-active-supplier   | 9001      | c1   | addr1 | email1  | manager1 | '13800000000'  | user1   | '2024-01-01 00:00:00' | '2024-01-02 00:00:00' | true      |
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
        body.json.data: | supplier_name         |
                        | tenant-current-only   |
        """

  Rule: 详情 - GET /supplier?id={id}

    场景: 根据id获取供应商成功
      假如存在"供应商":
        | supplierName   | city | address | email  | manager  | contactTel  | creator | createTime           | lastUpdateTime       | valid | tenantId |
        | get-supplier-1 | c1   | addr1   | email1 | manager1 | 13800000000 | user1   | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  | 9001     |
      当GET "/supplier?id=${供应商.supplierName[get-supplier-1].id}"
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= {
            id: 1
            supplier_name: get-supplier-1
            city: c1
            address: addr1
            email: email1
            manager: manager1
            contact_tel: '13800000000'
            creator: user1
            create_time: '2024-01-01 00:00:00'
            last_update_time: '2024-01-02 00:00:00'
            is_valid: true
            tenant_id: 9001
          }
        }
        """

    场景: 根据不存在的id获取供应商失败
      当GET "/supplier?id=999"
      那么response should be:
        """
        : {
          code: 200
          body.json: {
            isSuccess: false
            code: 400
            errorMessage: "数据不存在或已被删除"
          }
        }
        """

  Rule: 新增 - POST /supplier

    场景: 新增供应商成功并写入数据库
      当POST "/supplier":
        """
        {
          "supplier_name": "create-supplier",
          "city": "Shanghai",
          "address": "Create Road",
          "email": "email1",
          "manager": "Bob",
          "contact_tel": "13800000002",
          "is_valid": true
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
        供应商= {
          id: 1
          supplierName: create-supplier
          city: Shanghai
          address: 'Create Road'
          email: email1
          manager: Bob
          contactTel: '13800000002'
          creator: e2e-login-hook-user
          tenantId: 9001
          valid: true,
          <<createTime,lastUpdateTime>> is AlmostNow
        }
        """

    场景: 新增同租户重名供应商失败且不会重复落库
      假如存在"供应商":
        | supplierName       |
        | duplicate-supplier |
      当POST "供应商创建请求" "/supplier":
        """
        {
          supplierName: duplicate-supplier
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "供应商名称:duplicate-supplier 已经存在"
          data: 0
        }
        """
      并且数据应为:
        """
        供应商: | supplierName       |
               | duplicate-supplier |
        """

    场景: 新增供应商允许与其他租户同名
      假如存在"供应商":
        | supplierName          | tenantId |
        | cross-tenant-add-name | 9002     |
      当POST "供应商创建请求" "/supplier":
        """
        {
          supplierName: cross-tenant-add-name
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
        供应商: | supplierName          | +tenantId |
               | cross-tenant-add-name | 9001      |
               | cross-tenant-add-name | 9002      |
        """

    场景大纲: 新增供应商缺少名称时校验失败
      当POST "供应商创建请求" "/supplier":
        """
        {
          <fieldName>: null
        }
        """
      那么response should be:
        """
        body.json: {
          code: 400
          errorMessage: "<errorMessage>"
        }
        """
      例子:
        | fieldName    | errorMessage |
        | supplierName | 供应商名称必填      |

    场景大纲: 新增供应商名称超长时校验失败
      当POST "供应商创建请求" "/supplier":
        """
        {
          <fieldName>: 'A'*(<maxLength>+1),
        }
        """
      那么response should be:
        """
        body.json: {
          code: 400
          errorMessage: "<errorMessage>"
        }
        """
      例子:
        | fieldName    | maxLength | errorMessage          |
        | supplierName | 256       | 供应商名称输入字符长度不能大于256个字符 |
        | address      | 256       | 详细地址输入字符长度不能大于256个字符  |
        | city         | 128       | 所在城市输入字符长度不能大于128个字符  |
        | email        | 128       | Email输入字符长度不能大于128个字符 |
        | manager      | 64        | 负责人输入字符长度不能大于64个字符    |
        | contactTel   | 64        | 联系方式输入字符长度不能大于64个字符   |

  Rule: 修改 - PUT /supplier

    场景: 修改供应商成功
      假如存在"供应商":
        | supplierName    | city    | address     | manager | email           | contactTel  | valid | creator      | createTime           | lastUpdateTime       | tenantId |
        | update-supplier | Nanjing | Old Address | Carol   | old@example.com | 13800000006 | true  | e2e-supplier | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | 9001     |
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
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: true
        }
        """
      并且数据应为:
        """
        供应商= {
          id: 1
          supplierName: update-supplier-renamed
          city: Hangzhou
          address: 'New Address'
          email: new@example.com
          manager: David
          contactTel: '13800000007'
          creator: e2e-supplier
          tenantId: 9001
          valid: false
          createTime: '2024-01-01T00:00:00Z'
          lastUpdateTime is AlmostNow
        }
        """

    场景: 修改供应商为同租户重复名称失败
      假如存在"供应商":
        | supplierName              |
        | update-duplicate-target   |
        | update-duplicate-existing |
      当PUT "供应商修改请求" "/supplier":
        """
        {
          id: 1
          supplierName: update-duplicate-existing
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
      并且数据应为:
        """
        供应商: | id | supplierName              |
               | 1  | update-duplicate-target   |
               | 2  | update-duplicate-existing |
        """

    场景: 修改供应商允许与其他租户同名
      假如存在"供应商":
        | supplierName               | tenantId |
        | update-cross-tenant-source | 9001     |
        | update-cross-tenant-target | 9002     |
      当PUT "供应商修改请求" "/supplier":
        """
        {
          id: 1
          supplierName: update-cross-tenant-target
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
      并且数据应为:
        """
        供应商: | id | supplierName               | tenantId |
               | 1  | update-cross-tenant-target | 9001     |
               | 2  | update-cross-tenant-target | 9002     |
        """

    场景: 修改不存在的供应商失败
      当PUT "供应商修改请求" "/supplier":
        """
        {
          id: 999
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

    场景大纲: 修改供应商缺少名称时校验失败
      当PUT "供应商修改请求" "/supplier":
        """
        {
          <fieldName>: null
        }
        """
      那么response should be:
        """
        body.json: {
          code: 400
          errorMessage: "<errorMessage>"
        }
        """
      例子:
        | fieldName    | errorMessage |
        | supplierName | 供应商名称必填      |

  Rule: 删除 - DELETE /supplier?id={id}

    场景: 删除供应商成功
      假如存在"供应商":
        | supplierName    |
        | delete-supplier |
      当DELETE "/supplier?id=1"
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
        供应商= []
        """

    场景: 删除不存在的供应商失败
      当DELETE "/supplier?id=999"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "删除失败"
          data: null
        }
        """

  Rule: Excel批量导入 - POST /supplier/excel

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
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data: "保存成功"
        }
        """
      并且数据应为:
        """
        供应商: | id | supplierName          | city | address     | email               | manager | contactTel    | creator                | valid | tenantId | <<createTime,lastUpdateTime>> |
               | 1  | excel-supplier-1     | Wuxi | Excel Road 1 | excel1@example.com | Eva     | '13800000010' | e2e-login-hook-user  | true  | 9001L    | is AlmostNow |
               | 2  | excel-supplier-2     | Wuxi | Excel Road 2 | excel2@example.com | Frank   | '13800000011' | e2e-login-hook-user  | true  | 9001L    | is AlmostNow |
        """

    场景: Excel批量导入允许与其他租户同名
      假如存在"供应商":
        | supplierName            | tenantId |
        | excel-cross-tenant-name | 9002     |
      当POST "供应商导入请求[]" "/supplier/excel":
        """
        [{
          supplierName: excel-cross-tenant-name
        }]
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
      那么数据应为:
        """
        供应商: | supplierName            | +tenantId |
               | excel-cross-tenant-name | 9001      |
               | excel-cross-tenant-name | 9002      |
        """

    场景: Excel批量导入时文件内重名失败
      当POST "供应商导入请求[]" "/supplier/excel":
        """
        [{
          supplierName: excel-duplicate-in-payload
        } {
          supplierName: excel-duplicate-in-payload
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "供应商名称:excel-duplicate-in-payload 已经存在"
          data: null
        }
        """
      并且数据应为:
        """
        供应商: []
        """

    场景: Excel批量导入时与库内重名失败
      假如存在"供应商":
        | supplierName             |
        | excel-duplicate-existing |
      当POST "供应商导入请求[]" "/supplier/excel":
        """
        [{
          supplierName: excel-duplicate-existing
        }]
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "供应商名称:excel-duplicate-existing 已经存在"
          data: null
        }
        """
      并且数据应为:
        """
        供应商: | supplierName             |
               | excel-duplicate-existing |
        """
