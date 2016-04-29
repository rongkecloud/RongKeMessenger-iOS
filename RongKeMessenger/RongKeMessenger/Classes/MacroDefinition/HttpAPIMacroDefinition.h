//
//  HttpAPIMacroDefinition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/19.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_HttpAPIMacroDefinition_h
#define EnjoySkyLine_HttpAPIMacroDefinition_h

#import "HttpClientKit.h"

#pragma mark -
#pragma mark 登录注册

// 1.4.1. register.php（注册新用户）
#define HTTP_API_REGISTER [NSString stringWithFormat:@"%@://%@%@register.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.2. login.php（登录系统）
#define HTTP_API_LOGIN [NSString stringWithFormat:@"%@://%@%@login.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.3. modify_pwd.php（修改密码）
#define HTTP_API_MODIFY_PASSWORD [NSString stringWithFormat:@"%@://%@%@modify_pwd.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.4. add_feedback.php（问题反馈）
#define HTTP_API_FEEDBACK [NSString stringWithFormat:@"%@://%@%@add_feedback.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.5. check_update.php（检查更新）
#define HTTP_API_CHECK_UPDATA [NSString stringWithFormat:@"%@://%@%@check_update.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

#pragma mark -
#pragma mark 联系人相关

// 1.4.6 get_group_infos.php获取分组信息
#define HTTP_API_GET_CONTACT_GROUPS_INFO [NSString stringWithFormat:@"%@://%@%@get_group_infos.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.7. operation_group.php（操作分组信息）
#define HTTP_API_CONTACT_GROUPS_OPERATION [NSString stringWithFormat:@"%@://%@%@operation_group.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.8. get_friend_infos.php（获取好友信息）
#define HTTP_API_GET_FRIEND_INFOS [NSString stringWithFormat:@"%@://%@%@get_friend_infos.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

//1.4.9. operation_group_members.php（操作分组好友）
#define HTTP_API_OPERATION_CONTACT_GROUPS_MEMBERS [NSString stringWithFormat:@"%@://%@%@operation_group_members.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.10. get_personal_infos.php(批量获取个人信息)
#define HTTP_API_GET_PERSONAL_INFOS [NSString stringWithFormat:@"%@://%@%@get_personal_infos.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.11. operation_personal_info.php（操作个人信息）
#define HTTP_API_OPERATION_PERSONAL_INFO [NSString stringWithFormat:@"%@://%@%@operation_personal_info.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.12. add_friend.php（添加好友）
#define HTTP_API_ADD_FRIEND [NSString stringWithFormat:@"%@://%@%@add_friend.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.13. confirm_add_friend.php（确认加为好友）
#define HTTP_API_CONFIRM_ADD_FRIEND [NSString stringWithFormat:@"%@://%@%@confirm_add_friend.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.14. del_friend.php（删除好友）
#define HTTP_API_DELETE_FRIEND [NSString stringWithFormat:@"%@://%@%@del_friend.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.15. modify_friend_info.php（修改好友）
#define HTTP_API_MODIFY_FRIEND_INFO [NSString stringWithFormat:@"%@://%@%@modify_friend_info.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.16. get_avatar.php（获取头像）
#define HTTP_API_GET_AVATAR [NSString stringWithFormat:@"%@://%@%@get_avatar.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.17. upload_personal_avatar.php（上传头像）
#define HTTP_API_UPLOAD_PERSONAL_AVATAR [NSString stringWithFormat:@"%@://%@%@upload_personal_avatar.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]

// 1.4.18. search_contact_info.php（搜索好友）
#define HTTP_API_SEARCH_CONTACT_INFOS [NSString stringWithFormat:@"%@://%@%@search_contact_infos.php", RKCLOUD_URL_HTTP_TYPE, @"%@", RKCLOUD_API_SERVER_PATH]


#endif
