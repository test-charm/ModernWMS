# language: zh-CN
功能: 用户登录

  场景: 用户名和明文密码登录成功
    假如存在"用户角色":
      | role_name |
      | e2e-login-role |
    假如存在"用户":
      | user_name        | user_num        | auth_string                      |
      | login-user-plain | login-num-plain | 233e36c9678682b168a95b7cae20200b |
    当POST "/login":
    """
    {
      "user_name": "login-user-plain",
      "password": "plain-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: true
      code: 200
      errorMessage: ""
      data: {
        user_name: "login-user-plain"
        user_num: "login-num-plain"
        user_role: "e2e-login-role"
        tenant_id: 9001
        user_id: *
        userrole_id: *
        expire: *
        access_token: /.+/
        refresh_token: /.+/
      }
    }
    """

  场景: 工号和MD5密码登录成功
    假如存在"用户角色":
      | role_name |
      | e2e-login-role |
    假如存在"用户":
      | user_name      | user_num       | auth_string                      |
      | login-user-md5 | login-num-md5  | ff12cfc27d7a2b16f1f2572021225911 |
    当POST "/login":
    """
    {
      "user_name": "login-num-md5",
      "password": "ff12cfc27d7a2b16f1f2572021225911"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: true
      code: 200
      errorMessage: ""
      data: {
        user_name: "login-user-md5"
        user_num: "login-num-md5"
        user_role: "e2e-login-role"
        tenant_id: 9001
        user_id: *
        userrole_id: *
        expire: *
        access_token: /.+/
        refresh_token: /.+/
      }
    }
    """

  场景: 合法最大长度用户名和密码登录成功
    假如存在"用户角色":
      | role_name |
      | e2e-login-role |
    假如存在"用户":
      | user_name                                                                                                                         | auth_string                      |
      | UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU | def318e25ed57760834fcaba2cc56540 |
    当POST "/login":
    """
    {
      "user_name": "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU",
      "password": "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: true
      code: 200
      errorMessage: ""
      data: {
        user_name: "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"
        user_num: "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"
        user_role: "e2e-login-role"
        tenant_id: 9001
        user_id: *
        userrole_id: *
        expire: *
        access_token: /.+/
        refresh_token: /.+/
      }
    }
    """

  场景: 密码错误登录失败
    假如存在"用户角色":
      | role_name |
      | e2e-login-role |
    假如存在"用户":
      | user_name                  | auth_string                      |
      | login-user-wrong-password  | 233e36c9678682b168a95b7cae20200b |
    当POST "/login":
    """
    {
      "user_name": "login-user-wrong-password",
      "password": "wrong-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /登录失败/
    }
    """

  场景: 用户不存在登录失败
    当POST "/login":
    """
    {
      "user_name": "missing-user",
      "password": "any-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /登录失败/
    }
    """

  场景: 角色关联缺失登录失败
    假如存在"用户":
      | user_name           | auth_string                      |
      | login-user-no-role  | 3cc31cd246149aec68079241e71e98f6 |
    当POST "/login":
    """
    {
      "user_name": "login-user-no-role",
      "password": "no-role-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /登录失败/
    }
    """

  场景: 缺少用户名校验失败
    当POST "/login":
    """
    {
      "password": "valid-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /.*必填.*/
    }
    """

  场景: 缺少密码校验失败
    当POST "/login":
    """
    {
      "user_name": "login-user"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /.*必填.*/
    }
    """

  场景: 用户名超长校验失败
    当POST "/login":
    """
    {
      "user_name": "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU",
      "password": "valid-secret"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /.*不能大于128个字符.*/
    }
    """

  场景: 密码超长校验失败
    当POST "/login":
    """
    {
      "user_name": "login-user",
      "password": "QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ"
    }
    """
    那么response should be:
    """
    body.json: {
      isSuccess: false
      code: 400
      errorMessage: /.*不能大于64个字符.*/
    }
    """
