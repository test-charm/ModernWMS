# ModernWMS Copilot 指南

## 构建、测试、Lint 命令

```bash
# 前端
cd frontend
npm run dev
npm run build
npx eslint src --ext .ts,.vue

# 后端
cd backend
dotnet restore ModernWMS.sln
dotnet build ModernWMS.sln
dotnet run --project ModernWMS/ModernWMS.csproj

# 端到端 API 测试
cd e2e-tests
./gradlew cucumber
./gradlew cucumber -Pfile=src/test/resources/features/login.feature
./gradlew cucumber -Pfile=src/test/resources/features/login.feature:4
```

`backend/ModernWMS.sln` 里只有应用项目，没有 .NET 测试项目；自动化测试主要集中在 `e2e-tests`。Cucumber 默认连接 `127.0.0.1:53306` 的 MySQL 和 `127.0.0.1:20011` 的后端 API，这和 `docker-compose.yml` 的默认端口一致。

## 高层架构

- `backend/ModernWMS` 是 ASP.NET Core 启动宿主。`Program.cs` 很薄，绝大多数服务注册和中间件装配都放在 `ModernWMS.Core/Extentions/StartupExtensions.cs`。
- `backend/ModernWMS.Core` 放横切基础设施：EF Core 的 `SqlDBContext`、JWT/认证处理、各类中间件、本地化、Swagger、Hangfire 任务注册、通用 Controller/Service 基类，以及工具类。
- `backend/ModernWMS.WMS` 放仓储业务域代码：`Controllers/*` 下面是 API 控制器，`Services/*` 下面是业务实现，`Entities/*` 下面是实体和视图模型。
- `frontend` 是 Vue 3 + TypeScript + Vite 单页应用，使用 Vuex、Vuetify、VXE Table 和 vue-i18n。它直接请求后端 API，请求基地址由 `VITE_BASE_PATH` 和 `VITE_SERVER_PORT` 组合出来。
- `e2e-tests` 是独立的 Gradle/Cucumber API 测试工程。它会通过 JPA/JFactory 直接准备 MySQL 数据，再通过 HTTP 调后端接口。
- `docker-compose.yml` 是本地联调最省事的入口：MySQL 暴露在 `53306`，ASP.NET 应用在容器内监听 `5555`、宿主机映射成 `20011`，前端构建产物由 nginx 在 `58080` 提供服务。

## 关键约定

- 后端接口统一走现有的 `ResultModel<T>` 响应包裹。业务成功与否主要看 `isSuccess`、`code`、`errorMessage`、`data`，不要只靠 HTTP 状态码判断；模型校验失败、鉴权失败、普通控制器返回都遵循这个结构。
- 新的 API 控制器通常继承 `BaseController`。这个基类已经带了 `[Authorize]` 和 `ApiLogFilter`，所以接口默认需要登录；只有明确公开的接口才额外加 `[AllowAnonymous]`。
- 服务注册走约定优于配置。`StartupExtensions.RegisterAssembly()` 会扫描 `ModernWMS*.dll`，自动把实现类注册到继承 `IDependency` 的接口上；新增服务时优先沿用现有的 `IThingService` + `ThingService` 模式，不要手写零散 DI。
- EF Core 也是约定式用法。`SqlDBContext` 会扫描已加载的 `ModernWMS*.dll`，把继承 `BaseModel` 的类型当作实体注册；业务服务里习惯用 `_dBContext.GetDbSet<TEntity>()`，而不是额外声明 `DbSet<>` 属性。
- 前端路由是数据驱动的。登录后 `/rolemenu/authority` 会返回菜单元数据（`vue_path`、`vue_directory`、`module`），前端再把它转换成动态路由和侧边栏；新页面必须保证后端菜单配置和 `frontend/src/view/<vue_directory>/<vue_path>.vue` 文件路径一致。
- 侧边栏名称和图标集中写在 `frontend/src/utils/router/index.ts` 里。新增菜单时，通常不只要补页面文件，还要同步更新这里的映射逻辑。
- 前端 API 调用统一走 `frontend/src/utils/http/request.ts`。这里会自动注入 `culture` 查询参数、附带 Bearer Token、通过 `/refresh-token` 刷新令牌，并在调用方传入 `logTemp` 时补充审计头 `X-Vue-Path` 和 `X-Action-Content`。
- `user` 和 `system` 两个 Vuex 模块会通过 `vuex-persist` 持久化到 localStorage，所以登录态、菜单数据和部分界面偏好会跨刷新保留。
- 前后端本地化是联动的：前端发送 `culture=zh-cn` 或 `culture=en-us`，后端默认也只注册这两种 culture。
- 前端请求层实际上没有使用 `VITE_BASE_API`；如果要调整 API 路径规则，需要同时检查 `frontend/src/utils/http/request.ts` 和对应环境变量，不要只改 `.env`。
