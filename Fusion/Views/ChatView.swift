//
//  ChatView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 15/04/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @StateObject var viewModel = ChatViewModel()
    @State var chatText = "" //new chat that user is writing that is wrote - before it is sent
    @State var chats: [Chat] = [] //chat between the two users
    @State var placeholder = "What's on your mind?"
    @State var textEditorHeight : CGFloat = 20
    static let emptyScrollToString = "Empty"
     var sortedChats: [Chat] {
        return chats.sorted(by: { $0.createdAt < $1.createdAt })
    }
    let messageThread: MessageThread
    var currentUserID: String = {
        return Auth.auth().currentUser?.uid ?? ""
    }()
    
    private func SentMessage(chat: Chat) -> some View {
        HStack{
            Spacer()
            Text(chat.text)
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
                .padding()
                .background(Color.primaryTheme)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .padding(.trailing)
                .padding(.leading, 55)
        }
    }
    
    private func RecievedMessage(chat: Chat) -> some View {
        HStack{
            Text(chat.text)
                .font(.system(size: 15))
                .foregroundStyle(Color.black)
                .padding()
                .background(Color.textBubbleGrey)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .padding(.trailing, 55)
                .padding(.leading)
            Spacer()
        }
    }
    
    private var ChatBottomBar: some View {
        HStack{
            ZStack {
                Text(!chatText.isEmpty ? chatText : placeholder) //expands text editor in relative to how much user types in chat box
                                    .foregroundColor(Color("placeholder"))
                                    .padding(.leading)
                                    .background(GeometryReader {
                                        Color.clear.preference(key: ExpandableTextViewHeightKey.self,
                                                                value: $0.frame(in: .local).size.height)
                                    })
                                    .opacity(chatText.isEmpty ? 1 : 0)
             TextEditor(text: $chatText)
                    .frame(height: max(40, textEditorHeight))
                    .cornerRadius(6)
                    .padding(.leading)
            //        .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            
//            .frame(height: 40 )
            Button(action: {
                Firestore.firestore().collection("chats").addDocument(data: ["userID": currentUserID, "text": chatText, "threadID": messageThread.threadID, "createdAt": Date().timeIntervalSince1970 ])
                chatText = ""
            }, label: {
                Text("Send")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
            })
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .onPreferenceChange(ExpandableTextViewHeightKey.self) { textEditorHeight = ($0 + 18) }
    }

    
    var body: some View {
        VStack{
            ScrollView {
                ScrollViewReader(content: { proxy in
                    LazyVStack{
                        ForEach(sortedChats) { chat in
                            if chat.userID == currentUserID {
                                SentMessage(chat: chat)
                                    .id(chat.id)
                            }
                            else {
                                RecievedMessage(chat: chat)
                                    .id(chat.id)
                            }
                        }
                        HStack {
                            Spacer()
                        }
                        .id(Self.emptyScrollToString)
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }
                })
            }
            Spacer()
            ChatBottomBar
                  .padding(.bottom)
        }
        .onAppear(perform: {
            Firestore.firestore().collection("chats").whereField("threadID", isEqualTo: messageThread.threadID).addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else {
                    return
                }
                chats = snapshot.documents.compactMap({ Chat(snapshot: $0) })
                DispatchQueue.main.async {
                   viewModel.count += 1
                }
            }
            
        })
        .background(Color(.secondarySystemBackground))
//        .safeAreaInset(edge: .bottom) {
//
//            
//        }
    }
}

//#Preview {
//    ChatView(threadID: "", otherUserID: "")
//}

struct ExpandableTextViewHeightKey: PreferenceKey { //A key used to expand chat editor height according to how much user has typed
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
