//
//  widget.swift
//  widget
//
//  Created by Changyeol Seo on 2023/06/30.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct Provider: IntentTimelineProvider {
    var history:[HistoryModel.ThreadSafeModel] {
        let result:[HistoryModel.ThreadSafeModel] = Realm.shared.objects(HistoryModel.self)
            .sorted(byKeyPath: "date", ascending: false)
            .prefix(3)
            .map { model in
            return model.threadSafeModel
        }
        return result
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), history: history)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, history: history)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, history: history)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let history: [HistoryModel.ThreadSafeModel]
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    
    var historyView: some View {
        VStack(alignment: .leading) {
            ForEach(entry.history, id: \.self) { history in
                VStack(alignment: .leading) {
                    Text(try! AttributedString(markdown: history.value))
                        .foregroundColor(Color.textColorNormal)
                    if !history.isMemoEmpty {
                        Text(history.memo)
                            .font(.system(size: 10))
                            .foregroundColor(Color.textColorWeak)
                    }
                }
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary ,lineWidth: 2)
                    
                }
                .padding(.bottom,1)

            }
        }
    }
    
    var main: some View {
        Group {
            if entry.history.count == 0 {
                Image("launchImage")
                    .resizable()
                    .scaledToFill()
            } else {
                historyView
            }
        }
    }
    
    var body: some View {
        main
        .widgetBackground(backgroundView: Color.bg2)
        .padding(.top, 10)
    }
    
}

struct widget: Widget {
    let kind: String = "widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(),history: [
            .init(id: .init(), value: "8,865 `%` 8 `=` **70,920**", memo: "memo", date: Date()),
            .init(id: .init(), value: "8,865 `X` 8 `=` **70,920**", memo: "", date: Date()),
            .init(id: .init(), value: "8,865 `X` 8 `=` **70,920**", memo: "memo", date: Date()),

        ]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
