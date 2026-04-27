import { AudienceArrRes, AudienceRes, RequestAPI } from '@agctemplate/server';
import { container } from '@agctemplate/utils';
import { Audience } from 'live_interaction';
import { getMedia } from '@agctemplate/resources';

export function convertAudience(res: AudienceRes): Audience {
  return new Audience(res.id, getMedia(res.avatar), res.nickName, res.bio, res.followingList, res.followersList,
    res.likesCount,
    res.gender, res.isFocused)
}

export function convertAudienceArr(res: AudienceRes[]): Audience[] {
  let audienceArr: Audience[] = []
  res.map((value: AudienceRes) => {
    audienceArr.push(convertAudience(value))
  })
  return audienceArr;
}

export async function getFollowers(ids: string[]): Promise<Audience[]> {
  let res = await container.resolve(RequestAPI).getFollowers(ids)
  let audienceArr: Audience[] = [];
  (res.getBody() as AudienceArrRes).audienceArr.map((value: AudienceRes) => {
    audienceArr.push(convertAudience(value))
  })
  return audienceArr;
}

export async function getFollowing(ids: string[]): Promise<Audience[]> {
  let res = await container.resolve(RequestAPI).getFollowing(ids)
  let audienceArr: Audience[] = [];
  (res.getBody() as AudienceArrRes).audienceArr.map((value: AudienceRes) => {
    audienceArr.push(convertAudience(value))
  })
  return audienceArr;
}

export function setFollowing(id:string):void{

}

export function addFollowing(id: string): void {
  container.resolve(RequestAPI).addFollowing(id)
}

export function deleteFollowing(id: string): void {
  container.resolve(RequestAPI).deleteFollowing(id)
}

export async function getMyFollowing(): Promise<string[]> {
  let res = await container.resolve(RequestAPI).getMyFollowing()
  return res.getBody().audienceIdArr;
}

export async function getMyFollower(): Promise<string[]> {
  let res = await container.resolve(RequestAPI).getMyFollower()
  return res.getBody().audienceIdArr;
}
