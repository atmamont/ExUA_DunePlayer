//строчки конфигурации
var DUNE_IP = "[DUNE_IP]"; //IP adress of Dune player
var DUNE_START_PLAY = "http://" + DUNE_IP + "/cgi-bin/do?cmd=start_file_playback&media_url="; //init string

var list = document.getElementsByClassName('list')[0]; //выбираем таблицу со списком файлов
var rows = list.getElementsByTagName("tr"); //выбираем все ссылки в табличке

for (var i = 0; i < rows.length; i++) //цикл по всем ссылкам
{
    var oneHref=rows[i].getElementsByTagName("a")[0]; //выбираем первую ссылку (она как раз нам и нужна)

    var url = oneHref.href; // юрл в котором происходит поиск
    var regV = /get/gi;     // шаблон (ищем строку get в ссылке)
    var result = url.match(regV);  // поиск шаблона в юрл

    // Обработка результата
    if (result) {
        var DuneDiv = document.createElement('div');  //новый элемент див
        var DuneLink =DuneDiv.appendChild(document.createElement('a')); //будет новая ссылка
            DuneLink.id="dUneL";
            DuneLink.innerHTML='PLAY WITH DUNE';
            DuneLink.href=DUNE_START_PLAY+oneHref.href;
//            DuneLink.target="_blank";
        window.webkit.messageHandlers.notification.postMessage({body: DuneLink.href});
        var prNode=oneHref.parentNode;
        prNode.insertBefore(DuneDiv, oneHref);	//рисуем ссылку рядом с оригинальной
    } 
}
