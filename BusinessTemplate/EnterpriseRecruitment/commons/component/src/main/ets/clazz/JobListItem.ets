export class JobListItem {
  jobId: string
  recruitmentTag: number
  jobName: string
  address: number
  jobType: string
  publishTime: string
  recruitmentType: number
  responsibility: string
  requirements: string

  constructor(jobId: string, recruitmentTag: number, jobName: string, address: number, jobType: string,
    publishTime: string, recruitmentType: number, responsibility: string, requirements: string) {
    this.jobId = jobId
    this.recruitmentTag = recruitmentTag
    this.jobName = jobName
    this.address = address
    this.jobType = jobType
    this.publishTime = publishTime
    this.recruitmentType = recruitmentType
    this.responsibility = responsibility
    this.requirements = requirements
  }
}