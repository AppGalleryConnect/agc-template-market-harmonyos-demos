import { MockAdapter } from '@agctemplate/utils';
import {
  addMyFollowing,
  deleteMyFollowing,
  getAudience,
  getFeedLiveList,
  getFollower,
  getFollowing,
  getLiveByName,
  getLives,
  getMyFollower,
  getMyFollowing,
  getWatched,
  removeWatched,
  setWatched,
} from './mockLiveFactory';

// 设置模拟规则
MockAdapter
  .withDelay(100)
  .onGet({
    url: 'https://agc.template.com/getlivelist'
  }, () => {
    return {
      ret: {
        code: '0'
      },
      total: getFeedLiveList().length,
      liveList: getFeedLiveList()
    }
  })
  .onPost({
    url: 'https://agc.template.com/set/mywatchrecord'
  }, (config) => {
    let id:string = config.data
    setWatched(id)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/remove/mywatchrecord'
  }, (config) => {
    let ids = JSON.parse(config.data)
    removeWatched(ids)
    return {
      ret: {
        code: '0'
      }
    }
  })
  .onPost({
    url: 'https://agc.template.com/get/mywatchrecord'
  }, () => {
    return {
      ret: {
        code: '0'
      },
      liveList: getWatched()
    }
  })
  .onPost({
    url: 'https://agc.template.com/getFollower'
  }, (config) => {
    let ids = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceArr: getFollower(ids)
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/getFollowing'
  }, (config) => {
    let ids = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceArr: getFollowing(ids)
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/addFollowing'
  }, (config) => {
    let id = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceArr: addMyFollowing(id)
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/getAudience' 
  }, (config) => {
    let id = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceArr: getAudience(id)
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/deleteFollowing'
  }, (config) => {
    let id = JSON.parse(config.data)
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceIdArr: deleteMyFollowing(id)
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/getMyFollowing'
  }, (config) => {
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceIdArr: getMyFollowing()
    }
  }
  )
  .onPost({
    url: 'https://agc.template.com/getMyFollower'
  }, (config) => {
    return {
      ret: {
        code: '0'
      },
      total: 3,
      audienceIdArr: getMyFollower()
    }
  }
  )
  .onGet({
    url: 'https://agc.template.com/search'
  }, (config) => {
    let param = JSON.parse(config.data)
    let pageNum: number = param.pageNum
    let pageSize: number = param.pageSize
    let searchText: string = param.searchText
    let searchList = []
    let resultList = []
    getLives().forEach((name: string) => {
      if (name.indexOf(searchText) !== -1) {
        searchList.push(getLiveByName(name))
      }
    })

    if ((pageNum - 1) * pageSize > searchList.length) {
      // 超过范围了
      // return []
    } else {
      resultList = searchList.slice((pageNum - 1) * pageSize, Math.min(pageNum * pageSize, searchList.length))
    }
    return {
      ret: {
        code: '0'
      },
      total: resultList.length,
      liveList: resultList
    }
  })

  .onGet({
    url: 'https://agc.template.com/search/tip'
  }, (config) => {
    let searchText = JSON.parse(config.data)

    let searchTips: string[] = []
    if (searchText) {
      getLives().forEach((name: string) => {
        if (name.indexOf(searchText) !== -1) {
          searchTips.push(name)
        }
      })
    }

    return {
      ret: {
        code: '0'
      },
      total: searchTips.length,
      data: searchTips
    }
  })
