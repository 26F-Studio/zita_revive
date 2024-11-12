---@class OneBot.Sender CAUTION: May not accurate
---@field user_id number QQ号
---@field nickname string 昵称
---@field sex 'male'|'female'|'unknown'
---@field age number

---@class OneBot.Sender.Group : OneBot.Sender
---@field card string 群名片/备注
---@field area string 地区
---@field level string 等级
---@field role 'owner'|'admin'|'member'
---@field title string 专属头衔



---@class OneBot.SimpMes
---@field group? number
---@field user? number
---
---@field message string



---@class OneBot.Event.Base
---@field post_type 'message'|'notice'|'request'|'meta_event'
---@field time number

---@class OneBot.Event.Meta : OneBot.Event.Base
---@field post_type 'meta_event'
---@field meta_event_type 'lifecycle'|'heartbeat'
---@field sub_type 'connect'|'enable'|'disable'

---@class Segment
---@field type 'text'|'face'|'image'|'video'|'at'|'rps'|'dice'|'poke'|'anonymous'|'share'|'contact'|'location'|'music'|'reply'|'forward'|'node'|'xml'|'json'
---@field data table

---@class Segment.Text : Segment
---@field type 'text'
---@field data {text:string}

---@class Segment.At : Segment
---@field type 'at'
---@field data {qq:number,name:string}

---@class Segment.Reply : Segment
---@field type 'reply'
---@field data {id:number}

---@class OneBot.Event.PrivateMessage : OneBot.Event.Base
---@field post_type 'message'
---@field message_type 'private'
---@field sub_type 'friend'|'group'|'other'
---@field user_id number
---@field raw_message string
---
---@field sender OneBot.Sender
---@field message Segment[]
---
---@field font number
---@field message_id number

---@class OneBot.Event.GroupMessage : OneBot.Event.PrivateMessage
---@field message_type 'group'
---@field sub_type 'normal'|'anonymous'|'notice'
---@field group_id number
---@field sender OneBot.Sender.Group

---@alias OneBot.Event.Message OneBot.Event.PrivateMessage|OneBot.Event.GroupMessage


---@class OneBot.Event.FriendRequest : OneBot.Event.Base
---@field post_type 'request'
---@field request_type 'friend'
---@field self_id number 自己的QQ号
---@field user_id number 对方的QQ号
---@field comment string 验证信息
---@field flag string 请求flag，处理时传回

---@class OneBot.Event.GroupRequest : OneBot.Event.FriendRequest
---@field request_type 'group'
---@field sub_type 'add'|'invite'
---@field group_id number 群号

---@class OneBot.Event.Notice : OneBot.Event.Base
---@field TODO any

---@class OneBot.Event.Response
---@field retcode number
---@field status 'ok'|'async'
---@field wording string 未知
---@field data table 未知
---@field message string 未知
---@field echo? string
