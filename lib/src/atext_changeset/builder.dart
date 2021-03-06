part of otdartlib.atext_changeset;


/**
 * Creates a Changeset builder for the document.
 * @param {AttributedDocument} doc
 * @param? {String} optAuthor - optional author of all changes
 */
class Builder {
  ADocument _doc;
  int _len;
  String _author;
  ALinesMutator _mut;
  ComponentList _ops = new ComponentList();
  AttributeList _authorAtts;

  Builder(this._doc, {String author}) {
    this._author = author;
    _mut = _doc.mutate();
    _len = _doc.getLength();

    if(author != null) {
      _authorAtts = new AttributeList.fromMap(format: {'author': _author});
    } else {
      _authorAtts = new AttributeList();
    }
  }

  void keep(int N, int L) {
    _ops.addKeep(N, L);
    // mutator does the check that N and L match actual skipped chars
    _mut.skip(N, L);
  }

  void format(int N, int L, AttributeList attribs) => _format(N, L, attribs);

  void removeAllFormat(int N, int L) => _format(N, L, new AttributeList(), true);
  
  void _format(int N, int L, AttributeList attribs, [bool removeAll = false]) {
    // someone could send us author by mistake, we strictly prohibit that and replace with our author
    attribs = attribs.merge(_authorAtts);

    _mut.take(N, L).forEach((c) {
      c = c.clone(OpComponent.KEEP);
      if(removeAll) {
        c..invertAttributes()
          ..composeAttributes(attribs);
      } else {
        c.formatAttributes(attribs);
      }
      _ops.add(c);
    });
  }
  
  void insert(String text, [AttributeList attribs]) {
    attribs = attribs == null ? _authorAtts : attribs.merge(_authorAtts);
  
    var lastNewline = text.lastIndexOf('\n');
    if(lastNewline < 0) {
      // single line text
      _ops.addInsert(text.length, 0, attribs, text);
    } else {
      var l = lastNewline + 1;
      // multiline text, insert everything before last newline as multiline op
      _ops.addInsert(l, '\n'.allMatches(text).length, attribs, text.substring(0, l));
      if(l < text.length) {
        // insert remainder as single-line op
        _ops.addInsert(text.length - l, 0, attribs, text.substring(l));
      }
    }
  }
  
  void remove(int N, int L) => _ops.addAll(_mut.take(N, L).inverted);

  Changeset finish() => new Changeset(_ops, _len, author: _author);
}