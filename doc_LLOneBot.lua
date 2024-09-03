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



---@class LLOneBot.SimpMes
---@field group? number
---@field user? number
---
---@field message string



---@class LLOneBot.Event.Base
---@field post_type 'message'|'notice'|'request'|'meta_event'
---@field time number

---@class LLOneBot.Event.Meta : LLOneBot.Event.Base
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

---@class LLOneBot.Event.PrivateMessage : LLOneBot.Event.Base
---@field post_type 'message'
---@field message_type 'private'
---@field sub_type 'friend'|'group'|'other'
---@field user_id number
---@field raw_message string
---
---@field sender LLOneBot.Sender
---@field message Segment[]
---
---@field font number
---@field message_id number

---@class LLOneBot.Event.GroupMessage : LLOneBot.Event.PrivateMessage
---@field message_type 'group'
---@field sub_type 'normal'|'anonymous'|'notice'
---@field group_id number
---@field sender LLOneBot.Sender.Group

---@alias LLOneBot.Event.Message LLOneBot.Event.PrivateMessage|LLOneBot.Event.GroupMessage


---@class LLOneBot.Event.FriendRequest : LLOneBot.Event.Base
---@field post_type 'request'
---@field request_type 'friend'
---@field self_id number 自己的QQ号
---@field user_id number 对方的QQ号
---@field comment string 验证信息
---@field flag string 请求flag，处理时传回

---@class LLOneBot.Event.GroupRequest : LLOneBot.Event.FriendRequest
---@field request_type 'group'
---@field sub_type 'add'|'invite'
---@field group_id number 群号

---@class LLOneBot.Event.Notice : LLOneBot.Event.Base
---@field TODO any

---@class LLOneBot.Event.Response
---@field retcode number
---@field status 'ok'|'async'
---@field wording string 未知
---@field data table 未知
---@field message string 未知
---@field echo? string
