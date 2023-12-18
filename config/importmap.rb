pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.9/src/index.js"
pin "@firebase/app", to: "https://ga.jspm.io/npm:@firebase/app@0.9.25/dist/esm/index.esm2017.js"
pin "@firebase/messaging", to: "https://ga.jspm.io/npm:@firebase/messaging@0.12.5/dist/esm/index.esm2017.js"
pin "@firebase/component", to: "https://ga.jspm.io/npm:@firebase/component@0.6.4/dist/esm/index.esm2017.js"
pin "@firebase/installations", to: "https://ga.jspm.io/npm:@firebase/installations@0.6.4/dist/esm/index.esm2017.js"
pin "@firebase/logger", to: "https://ga.jspm.io/npm:@firebase/logger@0.4.0/dist/esm/index.esm2017.js"
pin "@firebase/util", to: "https://ga.jspm.io/npm:@firebase/util@1.9.3/dist/index.esm2017.js"
pin "idb", to: "https://ga.jspm.io/npm:idb@7.1.1/build/index.js"
