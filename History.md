
1.0.2 / 2012-06-24 
==================

  * 失误：改了 rack 的配置文件名却没改 `Prockfile` 的配置


1.0.1 / 2012-06-24 
==================

  * gtalk 密码分离到 config/config.yml 配置文件 准备开源

1.0.0 / 2012-06-24 
==================

  * 自动添加现有好友到数据库
  * 检测重复章节名（一般是因为前一贴被删才有新的同名贴) 优化章节名(去除第一个“第”之前的文字，并且多个空格和并成一个)
  * 增加 `-list`, `-sub`, `-unsub`, `-help`, `-about`, `-feedback` 命令
  * 使用 `Sidekiq` 作为队列实现
  * 使用 `Sequel` 作为 ORM 组件
  * 使用 `PostgreSQL` 做数据存储
  * REXML bug fix: 使用
  	(xmpp4r/issues/3)[https://github.com/ln/xmpp4r/issues/3#issuecomment-1739952] 补丁使 REXML 能正确处理 UTF 字符
