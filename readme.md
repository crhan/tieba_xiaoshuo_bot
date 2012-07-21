Howto?
=====

1. `yum install postgresql-devel libxslt-devel postgresql-server libxml2-devel`
1. `bundle install`
2. 改名 `mv config/config.yml{.example,}`
3. 填上自己的信息（ **数据库使用 `Sequel` 作为 ORM gem** ）
4. `rake migration`
5. `bundle exec foreman start`

Fetch Rules?
======

* 每五分钟扫描一遍对应小说贴吧的置顶帖，如果扫到包含 *第xxx章*
  字样的就认定是更新的小说章节，然后发给订阅者
* 依赖百度贴吧的“置顶贴”，严重感谢贴吧吧务们

Try?
====

* 用 Gtalk 加好友 `crhan.xiaoshuo@gmail.com`
* 发送 `-help` 给机器人查看帮助
* 发送 `-sub 小说名字` 即可订阅小说

---------
# Change Log

## 1.2.1 / 2012-07-21 

  * 修复 worker/send.rb:45 的 send NilClass 问题

## 1.2.0 / 2012-07-20 

  * model 的 before_create 和 before_save 改为 mixin 形式混入. 正常 model 直接继承 Sequel::Model
  * 加入等待, 确保在 `-check` 时候小说按照顺序分发
  * 增加 `check` 模式和 `-check` 命令 使用 `-mode` 切换模式
  * 增加 `-count` 命令

## 1.1.0 / 2012-07-13 

  * 增加gtalk XMPP extension 属性, 默认保存消息历史到 gtalk 服务器

## 1.0.6 / 2012-06-26 

  * 修复 1.0.3 引入的重复章节检测的 Typo

## 1.0.5 / 2012-06-25 

  * IQ 查询并发导致 users 重复创建, 在数据库上增加 unique 限制

## 1.0.4 / 2012-06-25 

  * 修正由于 Typo 导致的 Bot 崩溃

## 1.0.3 / 2012-06-25 

  * 章节名重复检测有误, 修正

## 1.0.2 / 2012-06-24 

  * 失误：改了 rack 的配置文件名却没改 `Prockfile` 的配置


## 1.0.1 / 2012-06-24 

  * gtalk 密码分离到 config/config.yml 配置文件 准备开源

## 1.0.0 / 2012-06-24 

  * 自动添加现有好友到数据库
  * 检测重复章节名（一般是因为前一贴被删才有新的同名贴) 优化章节名(去除第一个“第”之前的文字，并且多个空格和并成一个)
  * 增加 `-list`, `-sub`, `-unsub`, `-help`, `-about`, `-feedback` 命令
  * 使用 `Sidekiq` 作为队列实现
  * 使用 `Sequel` 作为 ORM 组件
  * 使用 `PostgreSQL` 做数据存储
  * REXML bug fix: 使用
  	(xmpp4r/issues/3)[https://github.com/ln/xmpp4r/issues/3#issuecomment-1739952] 补丁使 REXML 能正确处理 UTF 字符
