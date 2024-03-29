/* app/javascript/packs/application.js */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "controllers"
import "jquery"
import "bootstrap"
import "@fortawesome/fontawesome-free/css/all"
import "@yaireo/tagify"
import "@hotwired/turbo-rails"
import "@rails/request.js"

import "../../../vendor/assets/javascripts/spark"

import "../stylesheets/application"
import "../js/common";

window.Turbo = require("@hotwired/turbo")

// Toastr flash messages
global.toastr = require("toastr")
toastr.options.closeButton = true;
toastr.options.preventDuplicates = true;
toastr.options.timeOut = 30000;
toastr.options.extendedTimeOut = 60000;

Rails.start();
ActiveStorage.start();

require("trix")
require("@rails/actiontext")
