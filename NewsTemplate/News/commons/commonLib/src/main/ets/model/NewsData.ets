export class NewsData {
  public newsId: string;
  public newsTitle: string | Resource;
  public newsContent: string | Resource;
  public newsTime: string | Resource;
  public newsImage: string | Resource;

  toString(): string {
    return this.newsId + ' ' + this.newsTitle + ' ' + this.newsContent + ' ' + this.newsTime;
  }

  constructor(id: string, title: string | Resource, content: string | Resource, time: string | Resource,
    newsImage: string | Resource) {
    this.newsId = id;
    this.newsTitle = title;
    this.newsContent = content;
    this.newsTime = time;
    this.newsImage = newsImage;
  }
}