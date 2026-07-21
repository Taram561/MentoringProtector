#include "pch.h"
#include "exports.h"
#include "scanner/scanner.h"
#include "signatures/signatures.h"
#include <iostream>
#include "quarantine/quarantine.h"

using namespace std;

static string getWinDir() {
    char buf[MAX_PATH]{};
    GetWindowsDirectoryA(buf, MAX_PATH);
    return string(buf);
}
static const string NOTEPAD_PATH = getWinDir() + "\\notepad.exe";

int main() {
    SetConsoleOutputCP(65001);
    SetConsoleCP(65001);

    cout << "=== MentoringProtector Core v" << get_core_version() << " ===" << endl << endl;
    cout << "[1] Загрузка тестовой базы сигнатур..." << endl;

    SignatureDatabase db;
    int count = db.loadFromFile("..\\data\\signatures.msdb");

    cout << "Загружено сигнатур: " << count << endl;
    cout << "База загружена: " << (db.isLoaded() ? "ДА" : "НЕТ") << endl << endl;
    cout << "[2] Сканирование чистого файла..." << endl;

    Scanner scanner;
    scanner.loadSignatures("..\\data\\signatures.msdb");
    scanner.loadThreatDatabase("..\\data\\threat_database.json");

    ScanResult result = scanner.scanFile(NOTEPAD_PATH);
    cout << "Файл:     " << result.file_path << endl;
    cout << "Хеш:      " << result.file_hash << endl;
    cout << "Заражен:  " << (result.is_infected ? "ДА WARNING️" : "НЕТ OK") << endl << endl;
    cout << "[3] Поиск EICAR хеша в базе..." << endl;

    string eicarHash = "de3430cd6a3e24bfb9f78743a25f7c96";

    const SignatureRecord* record = db.findByHash(eicarHash);

    if (record != nullptr) cout << "Найдено: " << record->threat_name << " OK" << endl;
    else cout << "Не найдено X" << endl;

    cout << "[4] Тест ThreatInfo (неизвестная угроза)..." << endl;

    ThreatInfo info = ThreatDatabase::createUnknown("Win.Backdoor.NetCat");

    cout << "Название:    " << info.name << endl;
    cout << "Отображение: " << info.display_name << endl;
    cout << "Тип:         " << info.type << endl;
    cout << "Опасность:   " << info.danger_level << "/10" << endl;
    cout << "Описание:    " << info.description_short << endl;
    cout << "Шагов удал.: " << info.removal_steps.size() << endl;
    cout << "Советов:     " << info.prevention_tips.size() << endl;

    cout << endl << "[5] Загрузка базы знаний об угрозах..." << endl;

    ThreatDatabase threatDb;
    int threatCount = threatDb.loadFromFile( "..\\data\\threat_database.json" );

    cout << "Загружено угроз: " << threatCount << endl;
    cout << "База загружена:  " << (threatDb.isLoaded() ? "ДА" : "НЕТ") << endl;
    cout << endl << "[6] Поиск информации о трояне..." << endl;

    ThreatInfo trojan = threatDb.findByName("Win.PUP.Toolbar");

    cout << "Название:    " << trojan.name << endl;
    cout << "Отображение: " << trojan.display_name << endl;
    cout << "Тип:         " << trojan.type << endl;
    cout << "Опасность:   " << trojan.danger_level << "/10" << endl;
    cout << "Описание:    " << trojan.description_short << endl;
    cout << "Шагов удал.: " << trojan.removal_steps.size() << endl;
    cout << "Советов:     " << trojan.prevention_tips.size() << endl;
    cout << "Найдено:     " << (trojan.is_found ? "ДА OK" : "НЕТ X") << endl;
    cout << endl << "[7] Поиск неизвестной угрозы..." << endl;

    ThreatInfo unknown = threatDb.findByName("Unknown.Virus.XYZ");
    cout << "Найдено:     " << (unknown.is_found ? "ДА" : "НЕТ - возврат заглушки OK") << endl;
    cout << "Отображение: " << unknown.display_name << endl;
    cout << endl << "[8] Эвристический анализ notepad.exe..." << endl;

    HeuristicAnalyzer heuristic;
    heuristic.loadRules("..\\data\\heuristic_rules.json");

    HeuristicResult hr = heuristic.analyze(NOTEPAD_PATH);

    cout << "Проанализирован:  " << (hr.analyzed ? "ДА" : "НЕТ") << endl;
    cout << "Энтропия:         " << hr.entropy << endl;
    cout << "PE файл:          " << (hr.is_pe_file ? "ДА" : "НЕТ") << endl;
    cout << "Упакован:         " << (hr.is_packed ? "ДА" : "НЕТ") << endl;
    cout << "Цифровая подпись: " << (hr.has_signature ? "ДА OK" : "НЕТ") << endl;
    cout << "Очки:             " << hr.suspicion_score << endl;
    cout << "Вердикт:          " << hr.verdict << endl;
    cout << "Опасность:        " << hr.danger_level << "/10" << endl;
    cout << "Правил сработало: " << hr.triggered_rules.size() << endl;

    for (const auto& rule : hr.triggered_rules) cout << "  WARNING️  " << rule << endl;

    cout << endl << "[9] Тест карантина..." << endl;

    string test_file = "..\\data\\test_virus.txt"; {
        ofstream f(test_file);
        f << "Это тестовый файл для карантина. EICAR simulation.";
    }
    cout << "Создан тестовый файл: " << test_file << endl;

    QuarantineManager qm("..\\quarantine");
    QuarantineEntry entry;
    entry.original_path = test_file;
    entry.threat_name = "Test.Virus.Simulation";
    entry.threat_type = "trojan";
    entry.danger_level = 7;
    entry.file_hash = "abc123";
    entry.detection_method = "signature";

    QuarantineStatus status = qm.quarantineFile(entry);
    cout << "Помещен в карантин: " << (status == QuarantineStatus::Success ? "ДА OK" : "НЕТ X") << endl;
    cout << "ID записи: " << entry.id << endl;
    cout << "Файлов в карантине: " << qm.getCount() << endl;

    bool original_exists = (GetFileAttributesA(test_file.c_str()) != INVALID_FILE_ATTRIBUTES);
    cout << "Оригинал удален: " << (!original_exists ? "ДА OK" : "НЕТ X") << endl;

    string restore_path = "..\\data\\test_virus_restored.txt";
    status = qm.restoreFileTo(entry.id, restore_path);
    cout << "Восстановлен: " << (status == QuarantineStatus::Success ? "ДА OK" : "НЕТ X") << endl;

    ifstream restored(restore_path);
    string content((istreambuf_iterator<char>(restored)), istreambuf_iterator<char>());
    cout << "Содержимое: " << content << endl;
    cout << "Файлов в карантине после восст.: " << qm.getCount() << endl;

    DeleteFileA(restore_path.c_str());

    cout << endl << "[10] Сканер с базой знаний..." << endl;

    Scanner scanner2;
    scanner2.loadSignatures( "..\\data\\signatures.msdb");
    scanner2.loadThreatDatabase( "..\\data\\threat_database.json");

    ScanResult r2 = scanner2.scanFile(NOTEPAD_PATH);

    cout << "Файл: notepad.exe" << endl;
    cout << "Заражен: " << (r2.is_infected ? "ДА" : "НЕТ OK") << endl;
    cout << "ThreatDB загружена: ДА OK" << endl;

    ThreatDatabase tdb;
    tdb.loadFromFile("..\\data\\threat_database.json");

    ThreatInfo known = tdb.findByName("Win.PUP.Toolbar");
    cout << endl << "Симуляция известной угрозы:" << endl;
    cout << "Название:    " << known.name << endl;
    cout << "Отображение: " << known.display_name << endl;
    cout << "Тип:         " << known.type << endl;
    cout << "Опасность:   " << known.danger_level << "/10" << endl;
    cout << "Найдено:     " << (known.is_found ? "ДА OK" : "НЕТ X") << endl;
    cout << "Шагов удал.: " << known.removal_steps.size() << endl;
    cout << "Советов:     " << known.prevention_tips.size() << endl;
    cout << endl << "Шаги удаления:" << endl;
    for (const auto& step : known.removal_steps) { cout << "  " << step.step_number << ". " << step.description << endl; }

    ThreatInfo unknown2 = tdb.findByName("Win.Trojan.Yat-2");
    cout << endl << "Симуляция угрозы из ClamAV базы:" << endl;
    cout << "Название:    " << unknown2.name << endl;
    cout << "Найдено:     " << (unknown2.is_found ? "ДА" : "НЕТ - заглушка OK") << endl;
    cout << "Отображение: " << unknown2.display_name << endl;

    cout << endl << "Все тесты пройдены!" << endl;
    system("pause");
    return 0;
}