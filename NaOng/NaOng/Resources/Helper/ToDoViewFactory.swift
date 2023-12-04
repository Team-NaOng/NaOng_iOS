//
//  ToDoViewFactory.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/31.
//

import SwiftUI

class ToDoViewFactory {
    static func makeToDoMoldView<Content: View>(
        content: Content,
        RectangleCornerRadius: CGFloat = 10,
        lineWidth: CGFloat = 5,
        width: CGFloat = UIScreen.main.bounds.width - 60,
        height: CGFloat = 50,
        background: Color = Color("secondary")
    ) -> some View {
        return ZStack() {
            RoundedRectangle(cornerRadius: RectangleCornerRadius)
                .stroke(Color.black, lineWidth: lineWidth)
                .frame(width: width, height: height)
                .background(background)
            
            content
        }
        .cornerRadius(10)
    }
    
    static func makeToDoTextEditor(
        title: String,
        text: Binding<String>,
        width: CGFloat = UIScreen.main.bounds.width - 80,
        height: CGFloat = 140
    ) -> some View {
        return VStack(alignment: .leading) {
            ToDoViewFactory.makeToDoTitle(title: title)
            
            UITextViewWrapper(text: text)
            .frame(width: width, height: height)
            .cornerRadius(10)
        }
    }
    
    static func makeToDoTextField(
        title: String,
        text: Binding<String>
    ) -> some View {
        return HStack() {
            Image(systemName: "magnifyingglass")
            
            TextField(title, text: text)
        }
        .padding(20)
    }
    
    static func makeToDoDatePicker(
        selection: Binding<Date>,
        title: String,
        displayedComponent: DatePickerComponents,
        width: CGFloat = UIScreen.main.bounds.width - 80
    ) -> some View {
        return DatePicker(
            selection: selection,
            displayedComponents: displayedComponent) {
                ToDoViewFactory.makeToDoTitle(title: title)
        }
        .frame(width: width)
    }
    
    static func makeToDoToggle(
        isOn: Binding<Bool>,
        title: String,
        width: CGFloat = UIScreen.main.bounds.width - 80,
        tintColor: Color = Color("primary")
    ) -> some View {
        return Toggle(isOn: isOn) {
            ToDoViewFactory.makeToDoTitle(title: title)
        }
        .frame(width: width)
        .tint(tintColor)
    }
    
    static func makeToDoPicker(
        title: String,
        selection: Binding<String>,
        width: CGFloat = UIScreen.main.bounds.width - 80
    ) -> some View {
        return HStack {
            ToDoViewFactory.makeToDoTitle(title: title)
                .frame(width: (width - 10) / 2, alignment: .leading)
            
            Picker("", selection: selection) {
                Text("위치").tag("위치")
                Text("시간").tag("시간")
            }
            .pickerStyle(.segmented)
            .frame(width: (width - 10) / 2, alignment: .trailing)
        }
        .frame(width: width)
    }
    
    static func makeAlarmTimeView(
        selection: Binding<Date>,
        title: String,
        displayedComponent: DatePickerComponents
    ) -> some View {
        return ToDoViewFactory.makeToDoDatePicker(
            selection: selection,
            title: title,
            displayedComponent: displayedComponent
        )
    }
    
    static func makeAlarmLocationView(
        width: CGFloat = UIScreen.main.bounds.width - 60,
        title: String,
        selectedLocation: String
    ) -> some View {
        return HStack {
            ToDoViewFactory.makeToDoTitle(title: title)
            
            Spacer()
            
            ToDoViewFactory.makeToDoTitle(title: selectedLocation)
                .lineLimit(1)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.black)
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .frame(width: width)
    }
    
    static func makeToDoTitle(
        title: String,
        fontName: String = "Binggrae",
        fontSize: CGFloat = 15,
        fontColor: Color = Color.black
    ) -> some View {
        return Text(title)
            .font(.custom(fontName, size: fontSize))
            .foregroundColor(fontColor)
    }
    
    static func makeToDoDetailMoldView<Content: View>(
        title: String,
        content: Content,
        width: CGFloat = UIScreen.main.bounds.width,
        height: CGFloat = 50,
        background: Color = Color("primary").opacity(0.5)
    ) -> some View {
        return VStack(spacing: 0) {
            HStack {
                ToDoViewFactory.makeToDoTitle(title: title)
                Spacer()
            }
            .padding()
            .background(background)
            .frame(width: width, height: height)
            
            content
        }
    }
}
