# language: zh-CN
@known-bug @api-login-tenantId-9001
功能: 商品类别设置 API 已知缺陷

  # 这些场景用于记录当前已知缺陷。
  # 默认回归通过 build.gradle 中的 `not @known-bug` 标签过滤排除。

  场景: 根据不存在的id获取商品类别应返回失败
    当GET "/category?id=999"
    那么response should be:
      """
      body.json= {
        isSuccess: false
        code: 400
        errorMessage: "数据不存在或已被删除"
        data: null
      }
      """

  场景: 修改商品类别状态时应同步所有子孙类别
    假如存在"商品类别":
      | categoryName      | parentId | valid |
      | status-root       | 0        | true  |
      | status-child      | 1        | true  |
      | status-grandchild | 2        | true  |
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
      商品类别: | id | categoryName      | parentId | valid |
               | 1  | status-root       | 0        | false |
               | 2  | status-child      | 1        | false |
               | 3  | status-grandchild | 2        | false |
      """

  场景: 删除商品类别时应同时删除所有子孙类别
    假如存在"商品类别":
      | categoryName      | parentId |
      | delete-root       | 0        |
      | delete-child      | 1        |
      | delete-grandchild | 2        |
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
