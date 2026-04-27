import { NewsEnum } from '../constants/Constants'

export interface BaseAv {
  id: string
  type: NewsEnum
  title: string
  description: string
  isFollow: boolean
  coverUrl: string
  total: number
  section: AvSection[]
}

export interface AvSection {
  id: string
  title: string
  duration: number
  updateTime: string
  sectionUrl: string
  coverUrl?: string
  needVip: boolean
}

export interface BaseProgram {
  id: string
  programList: BaseProgramItem[]
}

export interface BaseProgramItem {
  programId: string
  title: string
  duration: number,
  updateTime: string
  isEnd: boolean
}