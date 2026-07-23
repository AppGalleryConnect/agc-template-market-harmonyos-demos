let myHandler = async function (event, context, callback, logger) {
    logger.info(`Input event: ${JSON.stringify(event)}`);

    let hmSystem = {
        status: 1,
        msg: "success",
    };
    logger.info(`hmSystem: ${hmSystem}`);
    let recommendList = [
        {
            "id": "",
            "dramaInfo": {
                "id": "drama_9",
                "coverUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic1.png",
                "name": "双生归来",
                "description": "凤鸣集团的总裁苏南烟一直在寻找失散多年的双胞胎妹妹沈秋雨，却在终于找到妹妹时，得知已成为人妻的妹妹这些年一直饱受欺凌，苏南烟为妹妹撑起了腰，帮她跟渣男离婚并拿到女儿的抚养权，沈秋雨的生活在姐姐的帮助下终于迎来了希望。",
                "totalCount": 80,
                "latestUpdate": 3,
                "category": ["年代", "情感", "家庭"],
                "promotionalUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8",
                "actorInfo": [{
                    "id": "1",
                    "name": "徐梦圆",
                    "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png"
                }, {
                    "id": "2",
                    "name": "何瑞聪",
                    "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man1.png"
                }, {
                    "id": "3",
                    "name": "星野零",
                    "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man2.png"
                }],
                "popular": "180万",
                "curIndex": 3,
                "favoriteCount": 172,
                "isFavorite": false,
                "likeCount": 138,
                "isLike": false,
                "isVip": false,
                "duration": 30000
            }
        }, {
        "id": "",
        "dramaInfo": {
            "id": "drama_10",
            "coverUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic2.png",
            "name": "离开后，你才说爱我",
            "description": "贺启明因为林氏集团董事长的知遇之恩，与林氏签下三年合约，为林氏工作，助林氏上市，林董事长十分赏识贺启明，指婚他和自己的女儿林子萱。林子萱恩怨至极，总觉得贺启明是个废物，一心只相信自己的白月光李远，但李远其实是个没有工作能力又很贪心的骗子。最后贺启明掌管了龙跃集团，李远因为拿巨额回扣被警察带走，林氏集团破产。",
            "totalCount": 80,
            "latestUpdate": 4,
            "category": ["家庭", "悬疑"],
            "promotionalUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8",
            "actorInfo": [{
                "id": "1",
                "name": "墨瞳",
                "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png"
            }, {
                "id": "2",
                "name": "雷恩",
                "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man1.png"
            }],
            "popular": "190万",
            "curIndex": 4,
            "favoriteCount": 164,
            "isFavorite": false,
            "likeCount": 126,
            "isLike": false,
            "isVip": false,
            "duration": 23720
        }
    }, {
        "id": "",
        "dramaInfo": {
            "id": "drama_11",
            "coverUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic3.png",
            "name": "龙君的高冷女总裁",
            "description": "叶玄，一位英勇无畏的青年，以其超凡的武艺和坚定的意志，在江湖中闯出了赫赫威名。他拳打赵家嚣张跋扈的大少，以正义之名维护了弱小；又脚踩柳家蛮横无理的大舅哥，展现了不屈不挠的斗志",
            "totalCount": 80,
            "latestUpdate": 5,
            "category": ["职场", "年代", "穿越"],
            "promotionalUrl": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8",
            "actorInfo": [{
                "id": "1",
                "name": "赛博",
                "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png"
            }, {
                "id": "2",
                "name": "萧逸尘",
                "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man1.png"
            }, {
                "id": "3",
                "name": "柳随风",
                "avatar": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man2.png"
            }],
            "popular": "200万",
            "curIndex": 5,
            "favoriteCount": 148,
            "isFavorite": false,
            "likeCount": 153,
            "isLike": false,
            "isVip": false,
            "duration": 29840
        }
    }
    ]
    logger.info(`tableTitleArr: ${recommendList}`);
    let result = { hmSystem, recommendList };
    let res = new context.HTTPResponse(
        result,
        {
            "faas-content-type": "json",
        },
        "application/json",
        "200"
    );

    callback(res);
};

module.exports.myHandler = myHandler;
