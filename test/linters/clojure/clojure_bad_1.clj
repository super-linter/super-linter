(ns foo
  (:require
   [clojure.string :as str]
    ;; We're never using this namespace. Also, the namespaces aren't sorted.
   [clojure.set :as set]))

;; Here we made a typo, so the symbol is unresolved:
(but-last [1 2 3])

;; Clj-kondo knows about arities of clojure namespaces, but you can also teach
;; it about your libraries or own namespaces
(str/join)

;; foo has an arity of 2, but we're not actually using y
(defn foo-fn [x y]
  ;; this do is redundant:
  (do
    ;; this is handy for debugging, but please remove it before pushing your code:
    (def tmp_x x)
    (let [y (fn [] (inc x))]
      ;; the next let can be squashed together with the previous:
      (let [z y]
        ;; whoopsy, calling a local function with an incorrect number of args:
        (y x)
        ;; also wrong:
        (recur)))))

(letfn
 [(f [] (h 1))
  (h [] (f 1))])

(defn- private-fn [])
;; redefining it...
(defn- private-fn [])

(defn foo [] :foo)
;; Type error, because foo doesn't return a number!
(inc (foo))

;; I'm tired now, let's sleep...
;; Oops, not happening because of wrong amount of args:
(Thread/sleep 1000 1 2)

;; Here we switch to another namespace and require the previous:
(ns bar (:require [foo :as f]))

;; Wrong arity when calling a function from the previous namespace:
(f/foo-fn)

;; private:
(f/private-fn)

;; this won't pass the reader:
{:a 1 :a 2}
;; and neither will this:
#{1 1}
;; nor this:
{:a 1 :b}

(ns bar-test (:require [clojure.test :as t]))

(t/deftest my-tests
  ;; you're not actually testing something here:
  (odd? (inc 1)))