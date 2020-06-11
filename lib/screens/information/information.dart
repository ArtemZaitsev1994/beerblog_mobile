import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:flutter/material.dart';


class Information extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      drawer: MainDrawer(),
      body: _drawHomePageBody(context),
    );
  }

 Widget _drawHomePageBody(BuildContext context) {
  MediaQueryData queryData;
  queryData = MediaQuery.of(context);

  return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(children: <Widget>[
        Text(
          'Кратикий экскурс.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Text(
          'Это основное меню, где можно выбирать нужную категорию.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/menu.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'Список предметов котегорий кликабелен, можно посмотреть подробную инфу выбрав нужный предмет. Внизу находится навигация, сверху находится поле для поиска, пока что (08.06.2020) проиндексировано только название, в планах расширить возможности поиска',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/list_items.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'На данны момент (08.06.2020) доступна сортировка только такая. В планах размножить функционал, для более эффективного поиска.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/sorting.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'На карточке пива\\вина\\бара пользователи с аккаунтами могут выставлять лоту свою оценку. Формируется общая оценка (средняя) и также пользователь видит свою выставленную.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/change_rate.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'Пользователи с аккаунтами могут оставлять комментарии.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/comment.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'А самое главное, пользователи с аккаунтом могут добавлять своё.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/block.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'Здесь все стандартно. Поля с ** - обязательные.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/add_new_item.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
        Text(
          'Здесь можно найти мой контакт, попросить меня дать тебе акк, но скорее всего я тебе его не дам))))). Причина - будет много мусора',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Text(
          'Но если ты подносил мне нольпяшечку, с самого утра, когда я умирал, то ты имеешь права требовать с меня этот жалкий акк.',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        Image.asset('assets/inormation_screenshots/authorization.jpg', height: queryData.size.height * 0.8,),
        SizedBox(height: 10),
      ]));
  }
}
