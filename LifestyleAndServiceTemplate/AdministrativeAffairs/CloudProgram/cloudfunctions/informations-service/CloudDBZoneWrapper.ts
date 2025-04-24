import { information } from './data';

function padZero(num) {
  return num.toString().padStart(2, '0');
}

function formatDateTime(date) {
  const year = date.getFullYear();
  const month = padZero(date.getMonth() + 1);
  const day = padZero(date.getDate());
  const hour = padZero(date.getHours());
  const minute = padZero(date.getMinutes());
  const second = padZero(date.getSeconds());
  return `${year}-${month}-${day} ${hour}:${minute}:${second}`;
}

export class CloudDbZoneWrapper {
  async queryUserInfo(searchType, refreshType, logger) {
    logger.info(searchType, refreshType)
    if (searchType == 0) {
      if (refreshType === 'refresh') {
        information[searchType].content.splice(0, 1)
        information[searchType].content.unshift(
          {
            "title": "2025年城乡居民医保筹资工作如何安排？",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png.png?token=7fd4e908-6855-4e80-b895-b7c4e3bf7349",
            "date": "2024-10-29",
            "isHot": true
          },
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      } else if (refreshType === 'more') {
        information[searchType].content.push(
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      }
    }
    if (searchType == 1) {
      if (refreshType === 'refresh') {
        information[searchType].content.splice(0, 1)
        information[searchType].content.unshift(
          {
            "title": "2025年城乡居民医保筹资工作如何安排？",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png.png?token=7fd4e908-6855-4e80-b895-b7c4e3bf7349",
            "date": "2024-10-29",
            "isHot": true
          },
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      } else if (refreshType === 'more') {
        information[searchType].content.push(
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      }
    }
    if (searchType == 2) {
      if (refreshType === 'refresh') {
        information[searchType].content.splice(0, 1)
        information[searchType].content.unshift(
          {
            "title": "2025年城乡居民医保筹资工作如何安排？",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png.png?token=7fd4e908-6855-4e80-b895-b7c4e3bf7349",
            "date": "2024-10-29",
            "isHot": true
          },
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      } else if (refreshType === 'more') {
        information[searchType].content.push(
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      }
    }
    if (searchType == 3) {
      if (refreshType === 'refresh') {
        information[searchType].content.splice(0, 1)
        information[searchType].content.unshift(
          {
            "title": "2025年城乡居民医保筹资工作如何安排？",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png.png?token=7fd4e908-6855-4e80-b895-b7c4e3bf7349",
            "date": "2024-10-29",
            "isHot": true
          },
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      } else if (refreshType === 'more') {
        information[searchType].content.push(
          {
            "title": "2025 年医保新福利：跨省共济范围扩大，集采持续推进",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "国家医保局：第一版丙类药品目录计划年内发布",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2025 年医保改革：为百姓带来更多实惠与便利",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "医保部门将加快推进长期护理保险制度建设",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
          {
            "title": "2024 年医保基金收支平衡，2025 年持续优化保障",
            "cover": "https://agc-storage-drcn.platform.dbankcloud.cn/v0/zwmb-xlw7o/news%2Fimage.png(3).png?token=f74c67bc-8505-4b5d-a10c-fe73298651de",
            "access": "1740",
            "date": formatDateTime(new Date())
          },
        )
      }
    }
    return information
  }
}
