enum BookType{
  shan("山"),
  yi("医"),
  ming("命"),
  xiang("相"),
  bu("卜");

  final String name;
  const BookType(this.name);
}
class BookDicItem{
  String path;
  // 书籍名称
  String name;
  // 类型
  BookType type;
  BookDicItem(this.name, this.type, this.path);
}

List<BookDicItem> bookList= [
  BookDicItem("了凡四训", BookType.bu, "assets/book/了凡四训[明]袁了凡.pdf"),
  BookDicItem("八字命理学基础教程", BookType.bu, "assets/book/八字命理学基础教程.pdf"),
  BookDicItem("六爻古籍经典合集", BookType.bu, "assets/book/六爻古籍经典合集.pdf"),
  BookDicItem("紫微斗数精解速成", BookType.bu, "assets/book/吴情-紫微斗数精解速成.pdf"),
  BookDicItem("周易译注", BookType.bu, "assets/book/周易译注(黄寿祺,张善文).pdf"),
  BookDicItem("紫微斗数新诠", BookType.bu, "assets/book/慧心斋主-紫微斗数新诠.pdf"),
  BookDicItem("紫微斗数看婚姻", BookType.bu, "assets/book/慧心斋主-紫微斗数看婚姻.pdf"),
  BookDicItem("渊海子平", BookType.bu, "assets/book/渊海子平(宋初徐子平 [宋初徐子平]).epub"),
  BookDicItem("皇极经世书", BookType.bu, "assets/book/皇极经世书(邵雍).pdf"),
  BookDicItem("神奇之门", BookType.bu, "assets/book/神奇之门.pdf"),
];