(ns foo
  (:require
    [clojure.string :as str]))

(butlast [1 2 3])

(str/join "" "")

(defn foo-fn [x]
    (let [y (fn [] (inc x))]
        (y)))

(letfn
  [(f [g] (h g))
    (h [i] (f i))])

(defn foo [] 1)
(inc (foo))

(Thread/sleep 1000 1)

;; Here we switch to another namespace and require the previous:
(ns bar (:require [foo :as f]))

(f/foo-fn 1)

{:a 1 :b 2}
#{1 2}
{:a 1 :b 2}

(ns bar-test (:require [clojure.test :as t]))

(t/deftest my-tests
  (t/is (odd? (inc 1))))
