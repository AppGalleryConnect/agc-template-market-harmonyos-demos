# HarmonyOS 应用/元服务模板介绍

## 模板导览

<table>
  <tr>
    <th width="150px">分类</th>
    <th width="200px">模板名称</th>
    <th width="150px">文档</th>
  </tr>
  <tr>
    <td rowspan="2"><a href="#旅游">旅游</a></td>
    <td><a href="#综合酒店元服务模板">综合酒店元服务模板</a></td>
    <td><a href="./TravelTemplate/FullServiceHotel/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#景区元服务模板">景区元服务模板</a></td>
    <td><a href="./TravelTemplate/TouristAttraction/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td rowspan="3"><a href="#生活服务">生活服务</a></td>
    <td><a href="#医保元服务模板">医保元服务模板</a></td>
    <td><a href="./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#美业元服务模板">美业元服务模板</a></td>
    <td><a href="./LifestyleAndServiceTemplate/LifeBeauty/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#家政元服务模板">家政元服务模板</a></td>
    <td><a href="./LifestyleAndServiceTemplate/HouseholdService/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#美食">美食</a></td>
    <td><a href="#点餐元服务模板">点餐元服务模板</a></td>
    <td><a href="./FoodAndDrinkTemplate/CateringOrders//README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#教育">教育</a></td>
    <td><a href="#课程助手元服务模板">课程助手元服务模板</a></td>
    <td><a href="./EducationTemplate/SchoolLife//README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#医疗">医疗</a></td>
    <td><a href="#医院元服务模板">医院元服务模板</a></td>
    <td><a href="./MedicalTemplate/MedicalCare/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#社交">社交</a></td>
    <td><a href="#相亲交友元服务模板">相亲交友元服务模板</a></td>
    <td><a href="./SocialTemplate/SocialDating/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#工具">工具</a></td>
    <td><a href="#智慧家居应用模板">智慧家居应用模板</a></td>
    <td><a href="./ToolsTemplate//SmartHome/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td rowspan="2"><a href="#儿童">儿童</a></td>
    <td><a href="#儿童教育应用模板">儿童教育应用模板</a></td>
    <td><a href="./KidsTemplate/ChildrenEducation/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#月子中心元服务模板">月子中心元服务模板</a></td>
    <td><a href="./KidsTemplate/PostpartumCareCenter/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td rowspan="2"><a href="#商务">商务</a></td>
    <td><a href="#办公考勤应用模板">办公考勤应用模板</a></td>
    <td><a href="./BusinessTemplate/OfficeAttendance/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#企业招聘应用模板">企业招聘应用模板</a></td>
    <td><a href="./BusinessTemplate/EnterpriseRecruitment/README.md" target="_blank">快速开始</a></td>
  </tr>
  <tr>
    <td><a href="#汽车">汽车</a></td>
    <td><a href="#汽车保养应用模板">汽车保养应用模板</a></td>
    <td><a href="./CarsTemplate/CarBeautyCare/README.md" target="_blank">快速开始</a></td>
  </tr>
</table>

## 旅游

### 综合酒店元服务模板

**功能介绍**

本模板为综合酒店类元服务提供了常用功能的开发样例，模板主要分首页、会员和我的三大模块：

- 首页：提供公告、会员信息、热销商品的展示，支持酒店、餐饮、宴会厅的预订。

- 会员：展示不同等级的会员卡片和等级说明。

- 我的：展示会员等级，支持订单、账号的管理。

本模板已集成华为账号、地图、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、酒店位置定位导航和购买商品等功能。

<a href="./TravelTemplate/FullServiceHotel/README.md" target="_blank">详细说明</a>

| 首页 | 会员 | 我的 |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![首页](./TravelTemplate/FullServiceHotel/screenshots/首页.png) | ![会员](./TravelTemplate/FullServiceHotel/screenshots/会员.png) | ![我的](./TravelTemplate/FullServiceHotel/screenshots/我的.png) |

### 景区元服务模板

**功能介绍**

本模板为景区旅游类元服务提供了常用功能的开发样例，模板主要分首页、门票、导览、订单和我的五大模块：

- 首页：提供景区轮播展示、公告信息、主要服务导航、热门景点推荐、攻略游记推荐。
- 门票：展示门票列表，支持门票的预订。
- 导览：提供景点、餐饮、住宿、卫生间的位置导航。
- 订单：支持对所有订单的管理。
- 我的：支持账号登录，提供订单入口，支持旅客信息、地址的管理。

本模板已集成华为账号、通话、地图、音频等服务，只需做少量配置和定制即可快速实现华为账号的登录、一键拨打服务电话、景点位置定位导航、景点信息讲解和购买门票和商品等功能。

<a href="./TravelTemplate/TouristAttraction/README.md" target="_blank">详细说明</a>

| 首页                                                                     | 门票                                                                       | 导览                                                                      | 订单                                                                      | 我的                                                                     |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| ![image](TravelTemplate/TouristAttraction/screenshots/devices/home.jpeg) | ![image](TravelTemplate/TouristAttraction/screenshots/devices/ticket.jpeg) | ![image](TravelTemplate/TouristAttraction/screenshots/devices/guide.jpeg) | ![image](TravelTemplate/TouristAttraction/screenshots/devices/order.jpeg) | ![image](TravelTemplate/TouristAttraction/screenshots/devices/mine.jpeg) |

## 生活服务

### 医保元服务模板

**功能介绍**

本模板为医保元服务提供了常用功能的开发样例，模板主要分首页、服务、医保码、资讯、和我的五大模块：

- 首页：主要提供医保码展示，长辈模式，以及热点查询，便民服务等功能

- 服务：展示全部服务列表，支持搜索所需服务。

- 资讯：展示当前医保相关资讯，支持上拉刷新、下拉加载、以及跳转 h5 查看资讯详情

- 医保码：展示当前账号绑定的医保码，

- 我的：展示个人信息、关于我们，切换头像，并支持意见反馈。

本模板已集成华为账号、定位、地图等服务，只需做少量配置和定制即可快速实现华为账号的登录、位置定位等功能，从而快速完成相关功能的实现。

<a href="./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/README.md" target="_blank">详细说明</a>

| 首页                                                                                         | 服务                                                                                            | 我的                                                                                         | 资讯                                                                                         |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| ![首页](./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/screenshot/home.png) | ![服务](./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/screenshot/service.png) | ![我的](./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/screenshot/mine.png) | ![资讯](./LifestyleAndServiceTemplate/AdministrativeAffairs/Application/screenshot/news.png) |

### 美业元服务模板

**功能介绍**

本模板为美容行业（美甲美睫）类元服务提供了常用功能的开发样例，模板主要分首页和我的两大模块：

- 首页：提供商品卡、团购、推荐商品的展示，支持购买和预约。
- 我的：展示会员卡信息，支持订单、商品卡、团购信息的管理。

本模板已集成华为账号、推送、华为支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、预约提醒、购买商品等功能。

<a href="./LifestyleAndServiceTemplate/LifeBeauty/README.md" target="_blank">详细说明</a>

| 首页                                                                                    | 我的                                                                                    |
| --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| <img src="./LifestyleAndServiceTemplate/LifeBeauty/screenshots/首页.jpg" width="200px"> | <img src="./LifestyleAndServiceTemplate/LifeBeauty/screenshots/我的.jpg" width="200px"> |

### 家政元服务模板

**功能介绍**

本模板为家政类元服务提供了常用功能的开发样例，模板主要分首页、全部服务和我的三大模块：

- 首页：提供主要商品轮播图、常用类别菜单和精选服务列表，支持城市切换、商品搜索、商品价格咨询以及商品购买。

- 全部服务：展示全部品类的商品列表，支持切换城市、搜索商品。

- 我的：展示个人信息、我的订单、服务和工具以及部分商品列表，支持修改个人信息、管理订单、管理地址等。

本模板已集成华为账号、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、购买商品等功能。

<a href="./LifestyleAndServiceTemplate/HouseholdService/README.md" target="_blank">详细说明</a>

| 首页                                                                         | 全部服务                                                                             | 我的                                                                         |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| ![首页](./LifestyleAndServiceTemplate/HouseholdService/screenshots/首页.jpg) | ![全部服务](./LifestyleAndServiceTemplate/HouseholdService/screenshots/全部服务.jpg) | ![我的](./LifestyleAndServiceTemplate/HouseholdService/screenshots/我的.jpg) |

## 美食

### 点餐元服务模板

**功能介绍**

本模板为餐饮点餐类元服务提供了常用功能的开发样例，模板主要分点餐、订单和我的三大模块：

- 点餐：提供店铺、优惠券、商品详情、购物车的展示，支持提交订单。
- 订单：支持对不同状态下订单的管理。
- 我的：展示账号相关信息，支持钱包、优惠券和积分的查看，以及帮助中心。

本模板已集成预加载、华为账号、地图、华为支付、通话等服务，只需做少量配置和定制即可快速实现页面的快速加载、华为账号的登录、商家位置定位导航、购买餐饮和联系商家等功能。

<a href="./FoodAndDrinkTemplate/CateringOrders//README.md" target="_blank">详细说明</a>

| 点餐                                                                            | 订单                                                                           | 我的                                                                           |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| ![点餐](./FoodAndDrinkTemplate/CateringOrders/screenshots/Screenshot_order.png) | ![订单](./FoodAndDrinkTemplate/CateringOrders/screenshots/Screenshot_list.png) | ![我的](./FoodAndDrinkTemplate/CateringOrders/screenshots/Screenshot_mine.png) |

## 教育

### 课程助手元服务模板

**功能介绍**

本模板为课程助手类元服务提供了常用功能的开发样例，模板主要分首页和我的两大模块：

- 首页：展示今日课程、明日课程，以及学期所有课程。进入课程支持根据签到地点、签到码进行签到。
- 我的：展示账号相关信息，支持修改用户昵称、头像。

本模板已集成华为账号、定位服务，只需做少量配置和定制即可快速实现华为账号的登录、基于位置签到等功能。

<a href="./EducationTemplate/SchoolLife//README.md" target="_blank">详细说明</a>

| 首页                                                                | 我的                                                                |
| ------------------------------------------------------------------- | ------------------------------------------------------------------- |
| <img src="./EducationTemplate/SchoolLife/doc/1.jpeg" width="200px"> | <img src="./EducationTemplate/SchoolLife/doc/2.jpeg" width="200px"> |

## 医疗

### 医院元服务模板

**功能介绍**

本模板为医疗类元服务提供了常用功能的开发样例，模板主要分首页、消息和我的三大模块：

- 首页：提供就诊人基本信息，以及常用服务的入口。
- 消息：支持查看医院动态信息，以及我接收到的消息。
- 我的：支持账户管理，登录后可以管理就诊人信息，查询挂号记录和就诊报告。

本模板已集成华为账号、地图、支付、推送等服务，只需做少量配置和定制即可快速实现华为账号的登录并一键获取账号的手机号和头像、医院位置定位导航和缴费等功能。

<a href="./MedicalTemplate/MedicalCare/README.md" target="_blank">详细说明</a>

| 首页                                                                | 按科室挂号                                                          | 按医生挂号                                                          | 挂号支付                                                            | 报告查询                                                            |
| ------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------- |
| ![1](./MedicalTemplate/MedicalCare/screenshots/20250217105429.jpeg) | ![2](./MedicalTemplate/MedicalCare/screenshots/20250217105450.jpeg) | ![3](./MedicalTemplate/MedicalCare/screenshots/20250217105505.jpeg) | ![5](./MedicalTemplate/MedicalCare/screenshots/20250217105548.jpeg) | ![4](./MedicalTemplate/MedicalCare/screenshots/20250217105856.jpeg) |

## 社交

### 相亲交友元服务模板

**功能介绍**

本模板为社交类相亲交友平台的元服务提供了常用功能的开发样例，提供了用户推荐、相亲活动、广场、会员、个人中心等能力。模板主要分首页、广场、会员、我的四大模块：

- 首页：分为“推荐”和“活动”两个页签，默认的“推荐”页签展示系统推荐的用户信息。“活动”页签展示活动信息。
- 广场：分为“推荐”和“关注”两个页签。“推荐”页签展示系统推荐的（热门）的动态信息，“关注”页签展示当前用户关注的用户发布的动态信息。
- 会员：展示会员特权描述和会员订购入口。
- 我的：展示用户的个人信息、操作记录、以及择偶标准、我的动态、我的订单、设置的管理。

本模板已集成华为账号、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录和购买会员套餐等功能。

<a href="./SocialTemplate/SocialDating/README.md" target="_blank">详细说明</a>

| 首页                                                                              | 广场                                                                        | 会员                                                                          | 我的                                                                            |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| ![首页-推荐](./SocialTemplate/SocialDating/read_me_resource/Screenshot_Home1.jpg) | ![广场](./SocialTemplate/SocialDating/read_me_resource/Screenshot_Feed.jpg) | ![会员](./SocialTemplate/SocialDating/read_me_resource/Screenshot_Member.png) | ![我的](./SocialTemplate/SocialDating/read_me_resource/Screenshot_Personal.png) |

## 工具

### 智慧家居应用模板

**功能介绍**

本模板构建了一款包含设备添加、设备管理的智能家居应用，并构建了设备模拟端，实现与该模板的蓝牙、MQTT 交互，从而整体功能的闭环展示。模板主要分首页、产品和我的三大模块：

- 首页：提供添加设备的功能，支持自动扫描、扫码和手动添加三种方式。

- 产品：展示月激活量大的产品列表。

- 我的：提供账号管理、授权管理、意见反馈、帮助中心等功能。

<a href="./ToolsTemplate//SmartHome/README.md" target="_blank">详细说明</a>

| 首页                                                         | 产品                                                            | 我的                                                        | 设备模拟                                                                  |
| ------------------------------------------------------------ | --------------------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------- |
| ![首页](./ToolsTemplate/SmartHome/screenshots/homePage.jpeg) | ![产品](./ToolsTemplate/SmartHome/screenshots/productPage.jpeg) | ![我的](./ToolsTemplate/SmartHome/screenshots/minePage.png) | ![设备模拟](./ToolsTemplate/SmartHome/screenshots/device_simulation.jpeg) |

## 儿童

### 儿童教育应用模板

**功能介绍**

本模板为儿童教育类应用提供了常用功能的开发样例，模板主要分首页、VIP 和我的三大模块：

1、首页：通过精选、看动画、英语乐园、儿歌、学汉语多个 Tab 页展示不同类型的视频内容。

2、vip：提供会员信息展示，以及会员套餐的开通。

3、我的：提供登录，会员信息、观看历史管理，联系我们等功能。

本模板已集成华为账号服务，只需做少量配置和定制即可快速实现华为账号登录。

<a href="./KidsTemplate/ChildrenEducation/README.md" target="_blank">详细说明</a>

| 首页                                                                               | 会员                                                                              | 我的                                                                               |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| <img src= "./KidsTemplate/ChildrenEducation/screenshots/home.png" width="200px" /> | <img src= "./KidsTemplate/ChildrenEducation/screenshots/Vip.png" width="200px" /> | <img src= "./KidsTemplate/ChildrenEducation/screenshots/mine.png" width="200px" /> |

### 月子中心元服务模板

**功能介绍**

本模板为母婴行业（月子中心）类应用提供了常用功能的开发样例，模板主要分为首页、门店、活动和我的四大模块：

- 首页：提供品牌服务信息、附近门店情况的展示，支持电话咨询、参观预约等功能。

- 门店：根据附近或者城市获取门店信息，提供门店详情和套餐价目介绍，支持参观预约、地址导航、日程添加、手机号关联和电话咨询等功能。

- 活动：根据附近或者城市、活动类型获取活动信息，提供活动详情介绍，支持活动报名、电话咨询等功能。

- 我的：支持展示用户信息和隐私条款，支持门店、活动预约记录的管理、意见反馈、华为账号一键登录等功能。

本模板已集成华为账号、地图等服务，只需做少量配置和定制即可快速实现华为账号的登录、定位导航和预约门店、活动等功能。

<a href="./KidsTemplate/PostpartumCareCenter/README.md" target="_blank">详细说明</a>

| 首页                                                               | 门店                                                               | 活动                                                               | 我的                                                               |
| ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| ![首页](./KidsTemplate/PostpartumCareCenter/screenshots/首页.jpeg) | ![门店](./KidsTemplate/PostpartumCareCenter/screenshots/门店.jpeg) | ![活动](./KidsTemplate/PostpartumCareCenter/screenshots/活动.jpeg) | ![我的](./KidsTemplate/PostpartumCareCenter/screenshots/我的.jpeg) |

## 商务

### 办公考勤应用模板

**功能介绍**

本模板为商务办公考勤类应用提供了常用功能的开发样例，模板主要分打卡、待办、日程、我的四大模块：

- 打卡：提供考勤打卡、打卡记录查看、快捷打卡设置功能。

- 待办：提供日常待办任务的管理，支持待办创建、修改，列表显示待处理与已处理待办记录。

- 日程：提供日常日程管理，支持创建、修改日程以及同步日程至系统日历进行提醒。

- 我的：提供账号信息查看、头像修改、退出登录功能。

本模板已集成华为账号、地图、日历等服务，只需做少量配置和定制即可快速实现华为账号的登录、考勤打卡、待办和日程管理等功能。

<a href="./BusinessTemplate/OfficeAttendance/README.md" target="_blank">详细说明</a>

| 打卡                                                                 | 待办                                                                | 日程                                                                  | 我的                                                              |
| -------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------- |
| ![打卡](./BusinessTemplate/OfficeAttendance/screenshots/checkIn.jpg) | ![待办](./BusinessTemplate/OfficeAttendance/screenshots/agency.jpg) | ![日程](./BusinessTemplate/OfficeAttendance/screenshots/schedule.jpg) | ![我的](./BusinessTemplate/OfficeAttendance/screenshots/mine.jpg) |

### 企业招聘应用模板

**功能介绍**

本模板为企业招聘类应用提供了常用功能的开发样例，模板主要分首页、职位和我的三大模块：

- 首页：提供企业招聘 banner 轮播图、公司文化信息、企业生活等宣传介绍。

- 职位：支持不同地域和岗位类型的职位搜索、职位详情查看、简历投递和职位收藏功能。

- 我的：支持账号信息、简历信息、职位收藏信息和投递记录的查询和维护。

本模板已集成华为账号等服务，只需做少量配置和定制即可快速实现华为账号的登录功能。

<a href="./BusinessTemplate/EnterpriseRecruitment/README.md" target="_blank">详细说明</a>

| 首页                                                                                             | 职位                                                                                          | 我的                                                                                    |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| <img src= "./BusinessTemplate/EnterpriseRecruitment/pictures/首页-企业生活.jpg" width="200px" /> | <img src= "./BusinessTemplate/EnterpriseRecruitment/pictures/职位列表页.jpg" width="200px" /> | <img src= "./BusinessTemplate/EnterpriseRecruitment/pictures/我的.jpg" width="200px" /> |

## 汽车

### 汽车保养应用模板

**功能介绍**

本模板为汽车美容保养类应用提供了常用功能的开发样例，模板主要分首页、汽车服务和我的三大模块：

- 首页：提供附近店铺和推荐套餐的展示，支持保养、美容、预约等功能。

- 汽车服务：展示不同的优惠券、以及详细展示汽车美容、轮胎护理、保养等服务功能。

- 我的：展示我的订单、我的预约、我的优惠券、我的车辆、联系人信息

本模板已集成华为账号、地图服务，只需做少量配置和定制即可快速实现华为账号登录、店铺定位、基于位置查找店铺等功能。

<a href="./CarsTemplate/CarBeautyCare/README.md" target="_blank">详细说明</a>

| 首页                                                               | 汽车服务                                                               | 我的                                                       |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------------------- |
| ![homepage.jpg](./CarsTemplate/CarBeautyCare/picture/homepage.png) | ![carservice.jpg](./CarsTemplate/CarBeautyCare/picture/carservice.png) | ![mine.jpg](./CarsTemplate/CarBeautyCare/picture/mine.png) |

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
