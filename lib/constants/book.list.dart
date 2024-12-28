enum BookType {
  shan("山"),
  yi("医"),
  ming("命"),
  xiang("相"),
  bu("卜");

  final String name;
  const BookType(this.name);
}

class BookDicItem {
  final String name;
  final String path;
  final BookType type;

  const BookDicItem({
    required this.name,
    required this.path,
    required this.type,
  });
}

List<BookDicItem> bookList = [
  BookDicItem(name: "了凡四训", path: "assets/book/了凡四训[明]袁了凡.pdf", type: BookType.bu),
  BookDicItem(name: "八字命理学基础教程", path: "assets/book/八字命理学基础教程.pdf", type: BookType.ming),
  BookDicItem(name: "六爻古籍经典合集", path: "assets/book/六爻古籍经典合集.pdf", type: BookType.bu),
  BookDicItem(name: "紫微斗数精解速成", path: "assets/book/吴情-紫微斗数精解速成.pdf", type: BookType.ming),
  BookDicItem(name: "周易译注", path: "assets/book/周易译注(黄寿祺,张善文).pdf", type: BookType.bu),
  BookDicItem(name: "紫微斗数新诠", path: "assets/book/慧心斋主-紫微斗数新诠.pdf", type: BookType.ming),
  BookDicItem(name: "紫微斗数看婚姻", path: "assets/book/慧心斋主-紫微斗数看婚姻.pdf", type: BookType.ming),
  BookDicItem(name: "渊海子平", path: "assets/book/渊海子平(宋初徐子平 [宋初徐子平]).epub", type: BookType.ming),
  BookDicItem(name: "皇极经世书", path: "assets/book/皇极经世书(邵雍).pdf", type: BookType.bu),
  BookDicItem(name: "神奇之门", path: "assets/book/神奇之门.pdf", type: BookType.bu),
];

Map<BookType, List<BookDicItem>> categorizedBookList = {
  for (var type in BookType.values)
    type: bookList.where((book) => book.type == type).toList(),
};