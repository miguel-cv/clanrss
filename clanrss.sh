#/bin/bash
# TODO
# Parsear descripción para añadir al RSS

echo "Obteniendo lista completa de series...."
curl -s http://www.rtve.es/infantil/series/ |grep "<option value" | grep -v "todas" | cut -d'"' -f2 | cut -d'/' -f 4 > /tmp/listaseries
while read line           
do  
    echo "* Procesando:$line *"
    identificador=(`curl -s http://www.rtve.es/infantil/series/$line/ |grep "a rel=" | grep -v "section\|start\|help" | cut -d '"' -f2 | head -n1`)
    echo "* Identificador de la serie $line:$identificador *"
    curl -s http://www.rtve.es/infantil/components/$identificador/videos.xml.inc > /tmp/videos.xml.inc
    # Extraemos el thumbnail y la url del video
    cat /tmp/videos.xml.inc |grep thumbnail | cut -d '"' -f4,6 --output-delimiter="," > /tmp/listavideos
    # Principio del archivo rss
    echo "<rss version=\"2.0\" xmlns:media=\"http://search.yahoo.com/mrss/\">

    <channel>
	<title>$line</title>
	<link>http://www.rtve.es</link>
	<description>Parsear descripcion en un futuro</description>
" > /tmp/$identificador.xml
    i=1
    while IFS=, read thumbnail urlvideo
do
  echo "url thumbnail    -> [${thumbnail}]"
  echo "url del video    -> [http://www.rtve.es/infantil/components${urlvideo}]"
  titulo="`cat /tmp/videos.xml.inc|grep "<title>" | head -n $i | tail -n 1`"
  echo "titulo del video -> [${titulo}]"
  echo "Metiendo capitulo en el archivo rss..."
  echo "
	<item>
	$titulo
	<link>http://www.rtve.es</link>
	<media:content url=\"http://www.rtve.es/infantil/components${urlvideo}\" />
	<media:thumbnail url=\"${thumbnail}\" />
	</item> " >> /tmp/$identificador.xml
	i=`expr $i + 1`
done </tmp/listavideos
echo "

  </channel>

</rss>

" >> /tmp/$identificador.xml

echo "******** Siguiente serie ********"
done </tmp/listaseries
echo "******** TERMINADO ********"

