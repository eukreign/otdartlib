/*
 * ShareJS ottype API spec support
 */
part of otdartlib.ottypes;

class OT_atext extends OTTypeFactory<ADocument, Changeset> {
  static final _name = 'atext';
  static final _uri = 'https://github.com/dmitryuv/atext-changeset';
  
  ADocument create([String initial]) {
    if(initial != null) {
      return new ADocument.fromText(initial);
    } else {
      return new ADocument();
    }
  }
  
  @override
  String get name => _name;
  
  @override
  String get uri => _uri;
  
  @override
  ADocument apply(ADocument doc, Changeset op) {
    op.applyTo(doc);
    return doc;
  }

  @override
  Changeset compose(Changeset op1, Changeset op2) {
    return op1.compose(op2);
  }

  @override
  Changeset invert(Changeset op) {
    return op.invert();
  }

  @override
  Changeset transform(Changeset op, Changeset otherOp, String side) {
    return op.transform(otherOp, side);
  }

  Position transformPosition(Position p, Changeset otherOp, String side) {
    return p.transform(otherOp, side);
  }
}
