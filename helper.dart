library md5.htmlhelper;
import 'dart:html';

class NoValidator implements NodeValidator {
  bool allowsAttribute(Element element, String attributeName, String value) {
    return true;
  }

  bool allowsElement(Element element) {
    return true;
  }
}

NoValidator noValidator = new NoValidator();
