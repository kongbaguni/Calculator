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
        var result:[HistoryModel.ThreadSafeModel] = Realm.shared.objects(HistoryModel.self).map { model in
            return model.threadSafeModel
        }
        result.reverse()
        while result.count > 10 {
            _ = result.popLast()
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
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if(entry.history.count == 0) {
                    Image("launchImage")
                        .resizable()
                        .scaledToFill()
                }
                else {
                    ForEach(entry.history, id: \.self) { history in
                        Group {
                            HStack {
                                Text(try! AttributedString(markdown: history.value))
                                    .foregroundColor(Color.textColorNormal)
                                Spacer()
                            }
                            if(history.memo.isEmpty == false) {
                                HStack {
                                    Text(history.memo)
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.textColorWeak)
                                    Spacer()
                                }
                            }
                        }.padding(.bottom, 2)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                }
            }
            .padding(.top, 10)
        }
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
            .init(id: .init(), value: "8,865 `X` 8 `=` **70,920**", memo: "memo", date: Date()),
            .init(id: .init(), value: "8,865 `X` 8 `=` **70,920**", memo: "memo", date: Date()),

        ]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
