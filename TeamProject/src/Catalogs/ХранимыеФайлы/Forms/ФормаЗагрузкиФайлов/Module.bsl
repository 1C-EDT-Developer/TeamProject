
//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ
//

&НаКлиенте
Процедура СписокФайловПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	Отказ = Истина;
	ДобавитьФайлы();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ДобавитьФайлы()
	ВыполнитьДобавитьФайлы();	
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьДобавитьФайлы()
	ВыборФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ВыборФайла.МножественныйВыбор = Истина;
	ВыборФайла.Заголовок = НСтр("ru = 'Выбор файла'", "ru");
	ВыборФайла.Фильтр = НСтр("ru = 'Все файлы'", "ru") + " (*.*)|*.*";
	ВыборФайла.ПредварительныйПросмотр = Истина;
	Попытка
		МассивИменВыбранныхФайлов = Ждать ВыборФайла.ВыбратьАсинх();
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка выбора файлов'", "ru"));
	КонецПопытки;
	Если НЕ МассивИменВыбранныхФайлов = Неопределено Тогда
		Для каждого ИмяВыбранногоФайла Из МассивИменВыбранныхФайлов Цикл
			СписокФайлов.Добавить(ИмяВыбранногоФайла);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьКаталог()
	ВыполнитьДобавитьКаталог();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьДобавитьКаталог()
	ВыборФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	Попытка
		МассивИменВыбранныхКаталогов = Ждать ВыборФайла.ВыбратьАсинх();
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка выбора каталога'", "ru"));
		Возврат;
	КонецПопытки;
	Если МассивИменВыбранныхКаталогов = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ИмяВыбранногоКаталога = МассивИменВыбранныхКаталогов[0];
	Попытка
		НайденныеФайлы = Ждать НайтиФайлыАсинх(ИмяВыбранногоКаталога, "*.*", Истина);
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка поиска файлов'", "ru"));
		Возврат;
	КонецПопытки;
	Если НайденныеФайлы = Неопределено Или Не НайденныеФайлы.Количество() Тогда
		Возврат;
	КонецЕсли;
	Для каждого Файл Из НайденныеФайлы Цикл
		ЭтоФайл = Ждать Файл.ЭтоФайлАсинх();
		Если Не ЭтоФайл Тогда
			Продолжить;
		КонецЕсли;
		СписокФайлов.Добавить(Файл.ПолноеИмя);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Загрузить()
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	Если СписокФайлов.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Файлы не выбраны'", "ru");
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	ПомещаемыеФайлы = Новый Массив;
	Для каждого Файл Из СписокФайлов Цикл
		Описание = Новый ОписаниеПередаваемогоФайла(Файл.Значение, "");
		ПомещаемыеФайлы.Добавить(Описание);
	КонецЦикла;
	ВыполнитьЗагрузить(ПомещаемыеФайлы);
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьЗагрузить(ПомещаемыеФайлы)
	Попытка
		ПомещенныеФайлы = Ждать ПоместитьФайлыНаСерверАсинх(,, ПомещаемыеФайлы, УникальныйИдентификатор);
	Исключение
		Ждать ПредупреждениеАсинх(НСтр("ru='Ошибка помещения файлов'", "ru"));
		Возврат;
	КонецПопытки;
	Если НЕ ПомещенныеФайлы=Неопределено Тогда
		Для каждого Файл Из ПомещенныеФайлы Цикл
			СписокЗагруженныхФайлов.Добавить(Файл);
		КонецЦикла;
		Результат = Новый Структура(
			"СписокЗагруженныхФайлов, Владелец",
			СписокЗагруженныхФайлов, Владелец);
		Закрыть(Результат);
	Иначе
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Файлы не загружены'", "ru");
		Сообщение.Сообщить();
	КонецЕсли;
КонецПроцедуры
