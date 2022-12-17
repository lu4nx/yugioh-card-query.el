;;; An Emacs plugin for the ygopro card database.
;; yugioh-card-query.el ---

;; Copyright (C) 2022 lu4nx

;; Author: lu4nx <lx@shellcodes.org>
;; URL: https://github.com/lu4nx/yugioh-card-query.el
;; Created: 2022-12-17
;; Version: v0.1
;; License: GPLv3
;; Keywords: elisp, yugioh, ygopro


;;; Code:

(require 'cl)

(defvar ygo-db-conn (sqlite-open ygo-card-database))

(defun ygo-get-monster-race (race-code)
  (cl-case race-code
    (#x1ffffff "全种族")
    (#x1 "战士")
    (#x2 "魔法师")
    (#x4 "天使")
    (#x8 "恶魔")
    (#x10 "不死")
    (#x20 "机械")
    (#x40 "水")
    (#x80 "炎")
    (#x100 "岩石")
    (#x200 "鸟兽")
    (#x400 "植物")
    (#x800 "昆虫")
    (#x1000 "雷")
    (#x2000 "龙")
    (#x4000 "兽")
    (#x8000 "兽战士")
    (#x10000 "恐龙")
    (#x20000 "鱼")
    (#x40000 "海龙")
    (#x80000 "爬虫类")
    (#x100000 "念动力")
    (#x200000 "幻神兽")
    (#x400000 "创造神")
    (#x800000 "幻龙")
    (#x1000000 "电子界")
    (otherwise nil)))

(defun ygo-get-attribute (attribute-code)
  (cl-case attribute-code
    (#x01 "地")
    (#x02 "水")
    (#x04 "炎")
    (#x08 "风")
    (#x10 "光")
    (#x20 "暗")
    (#x40 "神")
    (otherwise nil)))

(defun ygo-get-card-type (type-code)
  (let ((monster '((#x4000000 . "连接")
                   (#x2000000 . "特殊召唤")
                   (#x1000000 . "灵摆")
                   (#x800000 . "超量")
                   (#x400000 . "卡通")
                   (#x2000 . "同调")
                   (#x1000 . "调整")
                   (#x4000 . "衍生物")
                   (#x800 . "二重")
                   (#x200 . "灵魂")
                   (#x80 . "仪式")
                   (#x40 . "融合")
                   (#x20 . "效果")
                   (#x10 . "通常")))
        (spell '((#x80000 . "场地")
                 (#x40000 . "装备")
                 (#x20000 . "永久")
                 (#x10000 . "速攻")
                 (#x80 . "仪式")))
        (trap '((#x100000 . "反击")
                (#x20000 . "永久")))
        (type (cond ((not (= 0 (logand type-code #x1))) 'monster)
                    ((not (= 0 (logand type-code #x2))) 'spell)
                    ((not (= 0 (logand type-code #x4))) 'trap)
                    (t nil))))
    (when type
      (let ((sub-type (seq-find (lambda (i)
                                  (= (car i) (logand type-code (car i))))
                                (symbol-value type)))
            (type-name (cl-case type
                         (monster "怪兽")
                         (spell "魔法")
                         (trap "陷阱"))))
        (if sub-type
            (format "%s/%s" type-name (cdr sub-type))
          type-name)))))

(defun ygo-query-db (number-or-name)
  (car (sqlite-select ygo-db-conn
                      "select texts.id, texts.name, texts.desc, datas.type,
datas.attribute, datas.level, datas.atk, datas.def, datas.race from texts, datas
where (texts.id=? or texts.name=?) and texts.id=datas.id"
                      (list number-or-name number-or-name))))

(defun ygo-query-card (number-or-name)
  (interactive "sCard number or name: ")
  (let ((query-ret (ygo-query-db number-or-name)))
    (if query-ret
        (let ((new-buffer (generate-new-buffer (format "YGO %s" number-or-name))))
          (cl-multiple-value-bind (number name desc type attribute
                                          level atk def race) query-ret
            (with-current-buffer new-buffer
              (insert-image (create-image (format "%s/%s.jpg"
                                                  ygo-pictures-path number)))
              (insert (format "\n\n%s（%s）\n" name number))
              (insert (format "\n【%s】\n" (ygo-get-card-type type)))
              (when (and (not (string-equal (ygo-get-card-type type) "魔法"))
                         (not (string-equal (ygo-get-card-type type) "陷阱")))
                (insert (format "\n等级：%d，%s族，属性：%s\n" level
                                (ygo-get-monster-race race)
                                (ygo-get-attribute attribute)))
                (insert (format "\n攻击力：%d，防御：%d\n" atk def)))
              (insert (format "\n%s\n" desc))
              (switch-to-buffer new-buffer))))
      (message "Not found"))))

(provide 'yugioh-card-query)

;;; yugioh-card-query.el ends here
