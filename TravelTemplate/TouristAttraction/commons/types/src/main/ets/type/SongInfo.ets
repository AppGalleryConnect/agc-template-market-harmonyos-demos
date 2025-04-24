/**
 * Music information entity class.
 */
export class SongItem {
  /**
   * Primary key ID.
   */
  id: number = 0;

  /**
   * Music name.
   */
  title: string = '';

  /**
   * Music author name.
   */
  singer: string = '';

  /**
   * Music file path information.
   */
  src: string = '';

  /**
   * Index of the current music list.
   */
  index: number = 0;

  /**
   * Lyric file path information.
   */
  lyric: string = '';
}

export class SongList extends Array<SongItem>  {}
