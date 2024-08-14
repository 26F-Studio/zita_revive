---@class LLOneBot.Sender CAUTION: May not accurate
---@field user_id number QQ号
---@field nickname string 昵称
---@field sex 'male'|'female'|'unknown'
---@field age number

---@class LLOneBot.Sender.Group : LLOneBot.Sender
---@field card string 群名片/备注
---@field area string 地区
---@field level string 等级
---@field role 'owner'|'admin'|'member'
---@field title string 专属头衔



---@class LLOneBot.Event.Base
---@field post_type 'message'|'notice'|'request'|'meta_event'
---@field time number

---@class LLOneBot.Event.Meta : LLOneBot.Event.Base
---@field post_type 'meta_event'
---@field meta_event_type 'lifecycle'|'heartbeat'
---@field sub_type 'connect'|'enable'|'disable'


---@class LLOneBot.Event.PrivateMessage : LLOneBot.Event.Base
---@field post_type 'message'
---@field message_type 'private'
---@field sub_type 'friend'|'group'|'other'
---@field user_id number
---@field raw_message string
---
---@field sender LLOneBot.Sender
---@field message table
---
---@field font number
---@field message_id number

---@class LLOneBot.Event.GroupMessage : LLOneBot.Event.Base
---@field message_type 'group'
---@field sub_type 'normal'|'anonymous'|'notice'
---@field group_id number
---@field sender LLOneBot.Sender.Group


---@class LLOneBot.Event.Request.Friend : LLOneBot.Event.Base
---@field post_type 'request'
---@field request_type 'friend'
---@field self_id number 自己的QQ号
---@field user_id number 对方的QQ号
---@field comment string 验证信息
---@field flag string 请求flag，处理时传回

---@class LLOneBot.Event.Request.Group : LLOneBot.Event.Request.Friend
---@field request_type 'group'
---@field sub_type 'add'|'invite'
---@field group_id number 群号
