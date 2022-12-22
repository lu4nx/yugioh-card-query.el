(require 'ert)

(ert-deftest test-ygo--get-monster-race ()
  (should (null (ygo--get-monster-race nil)))
  (should (null (ygo--get-monster-race 0)))
  (should (string= "龙" (ygo--get-monster-race #x2000)))
  (should (string= "魔法师" (ygo--get-monster-race #x2))))

(ert-deftest test-ygo--get-attribute ()
  (should (null (ygo--get-attribute nil)))
  (should (string= "地" (ygo--get-attribute #x1)))
  (should (string= "水" (ygo--get-attribute #x2)))
  (should (string= "神" (ygo--get-attribute #x40))))

(ert-deftest test-ygo--get-card-type ()
  (should (null (ygo--get-card-type nil)))
  (should (string= "怪兽/通常" (ygo--get-card-type #x17)))
  (should (string= "魔法" (ygo--get-card-type #x2)))
  (should (string= "陷阱" (ygo--get-card-type #x4))))
