import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
// Получение перечня книг содержащихся в определенном
// списке книг пользователя
class BooksFolderAPI extends BooksAPI {
  var finalCallback = null;
  var books = [];
  var path = "";
  var nextPageParam = null;
  var sid = null;

  // **************************************************************************
  function initialize(finalCallback, folderId) {
    self.finalCallback = finalCallback;
    path = "/foundation/api/folders/" + folderId + "/arts?limit=3";
  }

  // **************************************************************************
  function start() {
    var authentificator = new BooksAuthentificationAPI(
      self.method(:startGettingBooksList)
    );
    authentificator.start();
  }

  // **************************************************************************
  // Получение списка книг
  function startGettingBooksList() {
    sid = Application.Storage.getValue(SID);
    continueGettingBooksList();
  }

  // **************************************************************************
  //Продолжаем после авторизации
  function continueGettingBooksList() {
    var url = api_url + path;

    var context = { URL => url };

    var headers = commonHeaders(sid);
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };

    logger.debug("start: " + url);
    Communications.makeWebRequest(
      url,
      {},
      options,
      self.method(:onGettingBooksList)
    );
  }

  // **************************************************************************
  //Обрабатываем список книг
  function onGettingBooksList(code, dict_data, context) {
    if (code != 200) {
      // onError(getErrorMessage(code, dict_data, "Получение списка книг"));
      var msg = "Code: " + code;
      if (dict_data instanceof Lang.Dictionary) {
        if (
          dict_data["error"] != null and
          dict_data["error"]["title"] != null
        ) {
          msg += " " + dict_data["error"]["title"];
        }
      }
      logger.error("Получение списка книг Code: " + code + " " + dict_data);
      Communications.notifySyncComplete(msg);
      return;
    }
    //Добавляем очередную порцию книг к списку
    var books_array = dict_data["payload"]["data"];
    for (var i = 0; i < books_array.size(); i++) {
      var bookObj = books_array[i];
      var author = "";
      var persons = bookObj["persons"];

      for (var j = 0; j < persons.size(); j++) {
        var person = persons[j];

        if (person["role"].equals("author")) {
          author = person["full_name"];
          author = iofToFio(author);
          break;
        }
      }

      // Определяем с какого УРЛ будем качать книгу
      // Есть два варианта:
      // 1. /download_book_subscr/
      // 2. /download_book/
      //
      // Так это определяют сами литресовцы
      // !( e.is_free || e.is_draft_full_free || e.my_art_status > 0)
      // && t.is_available_with_subscription
      // && n.subscription.is_active
      // && "active_subscription" === t.art_subscription_status_for_user
      //
      // Мы немного упростим. Не будем проверять есть ли у пользователя
      // активная подписка. Просто если книга не бесплатная и не купленная
      // и доступна для подписчиков, пытаемся скачать с /download_book_subscr/
      // если у пользователя нет действующей подписки - его проблемы.

      var subscr = false;
      if (
        !(
          bookObj["is_free"] or
          bookObj["is_draft_full_free"] or
          bookObj["my_art_status"] > 0
        ) and
        bookObj["is_available_with_subscription"]
      ) {
        subscr = true;
      }

      books.add({
        BooksStore.BOOK_ID => bookObj["id"],
        BooksStore.BOOK_TITLE => bookObj["title"], //Возможно стоит подрезать до 30-40 символов???
        BooksStore.BOOK_AUTHOR => author, //Возможно стоит подрезать до 30-40 символов???
        BooksStore.BOOK_COVER_URL => website_url + bookObj["cover_url"],
        BooksStore.URL_SUBSCRIPTION => subscr,
      });
    }

    // Проверяем есть ли еще страницы для загрузки, и если есть,
    // повторяем загрузку
    var newPath = dict_data["payload"]["pagination"]["next_page"];
    if (newPath == null or newPath.equals("null")) {
      finalCallback.invoke(books);
    } else {
      path = "/foundation" + newPath;
      continueGettingBooksList();
    }
  }

  // **************************************************************************
  //Превращаем ИОФ в ФИО
  function iofToFio(name) {
    var str = name;
    var array = [];
    var ind = str.find(" ");
    while (ind != null) {
      var part = str.substring(null, ind);
      if (!part.equals(" ")) {
        array.add(part);
      }
      str = str.substring(ind + 1, null);
      ind = str.find(" ");
    }
    if (!str.equals("") and !str.equals(" ")) {
      array.add(str);
    }
    if (array.size() == 2) {
      return array[1] + " " + array[0];
    } else if (array.size() == 2) {
      return array[2] + " " + array[0] + " " + array[1];
    } else {
      return name;
    }
  }
}
