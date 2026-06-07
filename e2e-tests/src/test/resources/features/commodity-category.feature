# language: zh-CN
@api-login-tenantId-9001
功能: 商品类别设置 API

  Rule: 全列表 - GET /category/all

    场景: 全列表只返回当前租户商品类别和全部字段
      假如存在"商品类别":
        | categoryName   | parentId | creator | createTime           | lastUpdateTime       | valid | tenantId |
        | root-category  | 0        | user1   | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  | 9001     |
        | child-category | 1        | user2   | 2024-01-03T00:00:00Z | 2024-01-04T00:00:00Z | false | 9001     |
        | other-tenant   | 0        | user3   | 2024-01-05T00:00:00Z | 2024-01-06T00:00:00Z | true  | 9002     |
      当GET "/category/all"
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= | id | category_name  | parent_id | creator | create_time           | last_update_time       | is_valid |
                | 1  | root-category  | 0         | user1   | '2024-01-01 00:00:00' | '2024-01-02 00:00:00' | true     |
                | 2  | child-category | 1         | user2   | '2024-01-03 00:00:00' | '2024-01-04 00:00:00' | false    |
        }
        """

    场景: 全列表无数据时返回空数组
      当GET "/category/all"
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= []
        }
        """

  Rule: 详情 - GET /category?id={id}

    场景: 根据id获取商品类别成功
      假如存在"商品类别":
        | categoryName | parentId | creator | createTime           | lastUpdateTime       | valid |
        | get-category | 0        | user1   | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  |
      当GET "/category?id=1"
      那么response should be:
        """
        body.json= {
          isSuccess: true
          code: 200
          errorMessage: ""
          data= {
            id: 1
            category_name: get-category
            parent_id: 0
            creator: user1
            create_time: '2024-01-01 00:00:00'
            last_update_time: '2024-01-02 00:00:00'
            is_valid: true
          }
        }
        """

  Rule: 新增 - POST /category

    场景: 新增根级商品类别成功并写入数据库
      当POST "商品类别创建请求" "/category":
        """
        {
          categoryName: create-root-category
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
        商品类别= {
          id: 1
          categoryName: create-root-category
          parentId: 0
          creator: e2e-login-hook-user
          tenantId: 9001
          valid: true,
          <<createTime,lastUpdateTime>> is AlmostNow
        }
        """

    场景: 新增同租户重名商品类别失败且不会重复落库
      假如存在"商品类别":
        | categoryName       |
        | duplicate-category |
      当POST "商品类别创建请求" "/category":
        """
        {
          categoryName: duplicate-category
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品类别:duplicate-category 已经存在"
          data: 0
        }
        """
      并且数据应为:
        """
        商品类别: | categoryName       |
                 | duplicate-category |
        """

    场景: 新增商品类别允许与其他租户同名
      假如存在"商品类别":
        | categoryName      | tenantId |
        | cross-tenant-name | 9002     |
      当POST "商品类别创建请求" "/category":
        """
        {
          categoryName: cross-tenant-name
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
        商品类别: | categoryName      | +tenantId |
                 | cross-tenant-name | 9001      |
                 | cross-tenant-name | 9002      |
        """

    场景: 新增商品类别缺少名称时校验失败
      当POST "商品类别创建请求" "/category":
        """
        {
          categoryName: null
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品类别必填"
          data: null
        }
        """

    场景: 新增商品类别名称超长时校验失败
      当POST "商品类别创建请求" "/category":
        """
        {
          categoryName: 'A'*(32+1)
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品类别输入字符长度不能大于32个字符"
          data: null
        }
        """

  Rule: 修改 - PUT /category

    场景: 修改商品类别成功
      假如存在"商品类别":
        | categoryName   | parentId | creator     | createTime           | lastUpdateTime       | valid |
        | update-parent  | 0        | parent-user | 2024-01-01T00:00:00Z | 2024-01-02T00:00:00Z | true  |
        | update-target  | 0        | target-user | 2024-01-03T00:00:00Z | 2024-01-04T00:00:00Z | true  |
      当PUT "商品类别修改请求" "/category":
        """
        {
          id: 2
          categoryName: update-target-renamed
          parentId: 1
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
        商品类别: | id | categoryName          | parentId | creator      | tenantId | valid |
                 | 1  | update-parent         | 0        | parent-user  | 9001     | true  |
                 | 2  | update-target-renamed | 1        | target-user  | 9001     | true  |
        """

    场景: 修改商品类别为同租户重复名称失败
      假如存在"商品类别":
        | categoryName               |
        | update-duplicate-target    |
        | update-duplicate-existing  |
      当PUT "商品类别修改请求" "/category":
        """
        {
          id: 1
          categoryName: update-duplicate-existing
        }
        """
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "商品类别:update-duplicate-existing 已经存在"
          data: false
        }
        """
      并且数据应为:
        """
        商品类别: | id | categoryName              |
                 | 1  | update-duplicate-target   |
                 | 2  | update-duplicate-existing |
        """

    场景: 修改商品类别允许与其他租户同名
      假如存在"商品类别":
        | categoryName               | tenantId |
        | update-cross-tenant-source | 9001     |
        | update-cross-tenant-target | 9002     |
      当PUT "商品类别修改请求" "/category":
        """
        {
          id: 1
          categoryName: update-cross-tenant-target
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
        商品类别: | id | categoryName               | tenantId | valid |
                 | 1  | update-cross-tenant-target | 9001     | true  |
                 | 2  | update-cross-tenant-target | 9002     | true  |
        """

    场景: 修改不存在的商品类别失败
      当PUT "商品类别修改请求" "/category":
        """
        {
          id: 999
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

    场景: 修改商品类别状态时同步直接子类别
      假如存在"商品类别":
        | categoryName | parentId | valid |
        | status-root  | 0        | true  |
        | status-child | 1        | true  |
      当PUT "商品类别修改请求" "/category":
        """
        {
          id: 1
          categoryName: status-root
          valid: false
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
        商品类别: | id | categoryName | parentId | tenantId | valid |
                 | 1  | status-root  | 0        | 9001     | false |
                 | 2  | status-child | 1        | 9001     | false |
        """

  Rule: 删除 - DELETE /category?id={id}

    场景: 删除商品类别成功
      假如存在"商品类别":
        | categoryName    |
        | delete-category |
      当DELETE "/category?id=1"
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
        商品类别= []
        """

    场景: 删除商品类别时同时删除直接子类别
      假如存在"商品类别":
        | categoryName | parentId |
        | delete-root  | 0        |
        | delete-child | 1        |
      当DELETE "/category?id=1"
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
        商品类别= []
        """

    场景: 删除被商品引用的商品类别失败
      假如存在"商品类别":
        | categoryName        |
        | referenced-category |
      假如存在"商品":
        | categoryId |
        | 1          |
      当DELETE "/category?id=1"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "数据已被引用，不能删除"
          data: null
        }
        """
      并且数据应为:
        """
        商品类别: | categoryName        |
                 | referenced-category |
        """
      并且数据应为:
        """
        商品: | categoryId | tenantId |
             | 1          | 9001     |
        """

    场景: 删除不存在的商品类别失败
      当DELETE "/category?id=999"
      那么response should be:
        """
        body.json= {
          isSuccess: false
          code: 400
          errorMessage: "删除失败"
          data: null
        }
        """
