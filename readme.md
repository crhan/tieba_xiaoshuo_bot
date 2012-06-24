Howto?
=====

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
