﻿unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ComObj, Vcl.OleCtrls,
  SHDocVw;

type
  TForm1 = class(TForm)
    OpenFile_B1: TButton;
    FileName1: TEdit;
    OD: TOpenDialog;
    CreateHTML_B: TButton;
    PreView_WB: TWebBrowser;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure OpenFile_B1Click(Sender: TObject);
    procedure CreateHTML_BClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    // создание html документа
    procedure CreateHTMLFile;
    procedure WordParsing;
    procedure ParagraphParsing(paragraph: variant);
    procedure TableFormatting();
    procedure Contents();
  end;

var
  Form: TForm1;
  // html-файл
  HTMLFile: TStringList;
  // word-файл
  W: variant;
  // счетчик таблицы
  TableCount: integer;

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  W.activedocument.close;
  W.quit;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // задаем начальную директорию для OpenDialog
  OD.InitialDir := ExtractFilePath(Application.ExeName);
  // создаем документ, html
  HTMLFile := TStringList.Create;
end;

procedure TForm1.OpenFile_B1Click(Sender: TObject);
begin
  // если файл не выбран, то выходим
  { if (not OD.Execute) or (OD.FileName = '') then
    exit; }

  // загружаем тестовый документ
  W := CreateOleObject('Word.Application');
  // W.Documents.Open(OD.FileName, EmptyParam, True);
  W.Documents.Open('C:\Users\Public\Documents\Практика\test doc.docx',
    EmptyParam, True);
  W.activedocument.SaveAs
    ('C:\Users\Public\Documents\Практика\test doc_dublicate.docx');
  W.activedocument.close;
  W.Documents.Open
    ('C:\Users\Public\Documents\Практика\test doc_dublicate.docx');
  // W.Visible := True;
  // 'C:\Users\Public\Documents\Практика\Win32\Debug\test doc.docx'
  // пишем путь
  // FileName1.Text := OD.FileName;
  FileName1.Text :=
    'C:\Users\Public\Documents\Практика\Win32\Debug\test doc.docx';
end;

procedure TForm1.CreateHTML_BClick(Sender: TObject);
begin
  // создаем html-файл
  CreateHTMLFile;
  // сохраняем его
  HTMLFile.SaveToFile('C:\Users\Public\Documents\Практика\test.html');
  // открываем в браузере
  PreView_WB.Navigate('file://' +
    'C:\Users\Public\Documents\Практика\test.html');
end;

procedure TForm1.CreateHTMLFile;
begin
  // очищаем
  HTMLFile.Clear;
  // обращаемся к "html"
  with HTMLFile do
  begin
    contents();
    // пишем заголовок
    Add('<html>');
    Add('<head>');
    Add('<title>' + ExtractFileName(FileName1.Text) + '</title>' + #10#13 +
      '</head>');
    Add('<body>');
    // наполняем body
    WordParsing;
    Add('</body>');
    Add('</html>');
  end;
end;

procedure TForm1.WordParsing;
var
  i: integer;
  wordrange: variant;
  FontName, curFontName, AlignName: string;
  listFlag: boolean;
  CurTable, AlignNumb, curFontSize, FontSize: integer;
begin
  listFlag := False; // флаг для проверки списков
  TableCount := 1; // инициализируем счетчик таблиц
  CurTable := 1; // текущая таблица

  // цикл по абзацам
  for i := 1 to W.activedocument.Paragraphs.Count do
  begin
    wordrange := W.activedocument.Paragraphs.Item(i).range; // абзац

    AlignNumb := W.activedocument.Paragraphs.Item(i).Alignment;
    case AlignNumb of
    0:
    AlignName := 'Left';
    1:
    AlignName := 'Center';
    2:
    AlignName := 'Right';
    3:
    AlignName := 'Justify'
    end;

    wordrange := W.activedocument.Paragraphs.Item(i).range; // абзац

    curFontName := string('face = "' + string(wordrange.formattedText.Font.Name)
      + '"'); // название шрифта
    curFontSize := strTOInt(varToStr(wordrange.formattedText.Font.Size)); // название шрифта

    case curFontSize of
    12:
    curFontSize := 3;
    14:
    curFontSize := 4;
    18:
     curFontSize := 5;
    24:
     curFontSize := 6;
    end;

    // если текст жирный, передать абзац в функцию
    if (wordrange.formattedText.bold <> 0) and (wordrange.Tables.Count = 0) then
      ParagraphParsing(wordrange);

    // если текущий шрифт не совпадает с предыдущим
    if (curFontName <> FontName) or (curFontSize <> FontSize) then
    begin
      if wordrange.text = #13#7 then continue;

      wordrange.insertbefore('<font ' + curFontName + '" size = "' +
        intTOstr(curFontSize) + '">');
      if i <> 1 then
        wordrange.insertbefore('</font>');
      FontName := curFontName;
      FontSize := curFontSize;
    end;
    //если ныняшняя таблица закончилась, меняем CurTable
    if (CurTable <> TableCount) and (wordrange.Tables.Count = 0) then
    begin
      CurTable := CurTable + 1;
    end;

    //если параграф принадлежит таблице
    if (wordrange.Tables.Count > 0) then
    begin
      //если текущая таблица совпадает с TableCount
      if CurTable = TableCount then
        TableFormatting();
      continue;
    end;

    // если абзац находится в списке
    if (wordrange.listformat.listtype > 0) and
      (wordrange.listformat.listtype < 6) then
    begin
      if listFlag = False then
        HTMLFile.Append('<ul>');
      HTMLFile.Append('<li>' + string(wordrange.Text) + '</li>');
      listFlag := True;
      continue;
    end;
    if listFlag = True then
    begin
      HTMLFile.Append('</ul>');
      listFlag := False;
    end;


    HTMLFile.Append('<p ALIGN = "' + AlignName + '">' + string(wordrange.Text) + '</p>');

  end;
  HTMLFile.Append('</font>');
end;

procedure TForm1.ParagraphParsing(paragraph: variant);
var
  Flag: boolean;
  i: integer;
  isBold: integer;
begin
  // обратный цикл по словам в параграфе
  for i := paragraph.words.Count downto 1 do
  begin
    isBold := paragraph.words.Item(i).formattedText.bold;
    // проверка жирности слова
    // если текст жирный
    if isBold = -1 then
    begin
      if Flag = False then
        paragraph.words.Item(i).insertafter('</b>');
      Flag := True;
    end;
    // если текст не жирный
    if (isBold = 0) and (Flag = True) then
    begin
      paragraph.words.Item(i).insertafter('<b>');
      Flag := False;
    end;
  end;
  // проставляем открывающий тег, если первое слово жирное
  if Flag = True then
    paragraph.words.Item(1).insertbefore('<b>');
end;

procedure TForm1.TableFormatting();
var
  TableColumnsCount, TableRowsCount, CurrentRow, CurrentColumn: integer;
  text: string;
begin
  // Определяем количество столбцов
  TableColumnsCount := W.activedocument.Tables.Item(TableCount).Columns.Count;
  // Определяем количество строк
  TableRowsCount := W.activedocument.Tables.Item(TableCount).Rows.Count;
  HTMLFile.Append('<table border="4" bordercolor="#000000">');
  //перебираем по строкам/колонкам
  for CurrentRow := 1 to TableRowsCount do
  begin
    HTMLFile.Append('<tr>');
    for CurrentColumn := 1 to TableColumnsCount do
    begin
      text := W.activedocument.Tables.Item(TableCount)
        .Cell(CurrentRow, CurrentColumn).range.Text;
        //memo1.Lines.Add(intToStr(length(text)));

      if length(text) > 2 then
      begin
         HTMLFile.Append('<th>' + Copy(text, 1,Length(text) - 1) + '</th>');
      end;
      if length(text) = 2 then HTMLFile.Append('<th>' + '&nbsp;' +'</th>');

    end;
    HTMLFile.Append('</tr>');
  end;

  HTMLFile.Append('</table>');

  TableCount := TableCount + 1;
end;

procedure TForm1.Contents();
var
i: integer;
link: variant;
begin

  for i := 1 to w.activedocument.hyperlinks.count do
  begin
      link := w.activedocument.hyperlinks.item(i);
      link.range.insertbefore('<a HREF = "#' + intToStr(i) + '">');
      link.range.insertafter('</a>');
      link.follow;
      w.selection.insertbefore('<a NAME = "#'+ intToStr(i) + '">');
      w.selection.insertafter('</a>');
  end;


end;
end.

{
  Надо сделать:
  1. оглавление
  2. типы списков
  3. таблицы
  4. картинки
  5. косметика (выравнивание)
}

{
hyperlinks(item)
.follow
.range.text
.add anchor
}
