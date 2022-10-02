//
//  ChatViewController.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 28.08.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()
        
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    private let refreshController = UIRefreshControl()
    
    private let micButton = InputBarButtonItem()
    
    var mkMessages = [MKMessage]()
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    //Listeners
    var notificationToken: NotificationToken?
    
    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    //MARK: - Setup
    private func setup() {
        
        view.backgroundColor = .secondarySystemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        configureLeftBarButton()
        configureCustomTitle()
        
        setupBackgroundTap()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
        
        createTypingObserver()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    
    //MARK: - Configurations
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
        
    }
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside { item in
            
            print("attach button pressed")
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //add a gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        updateMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .secondarySystemBackground
        messageInputBar.inputTextView.backgroundColor = .secondarySystemBackground
        
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
        
    }
    
    private func configureLeftBarButton() {
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
        
    }
    
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        titleLabel.text = recipientName
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
    }
    
    private func setupBackgroundTap() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func backgroundTap() {
        view.endEditing(false)
    }
    
    @objc private func swipeRightAction() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: - LoadChats
    private func loadChats() {
        
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            //updated message
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
                
            case .error(let error):
                print("error on new insertion: ", error.localizedDescription)
            }
            
        })
        
    }
    
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    //MARK: - Insert messages
    private func insertMessages() {
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            
            insertOlderMessage(allLocalMessages[i])
        }
        
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId && localMessage.status != kREAD {
            FirebaseMessageListener.shared.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recipientId])
        }
        
    }
    
    private func listenForReadStatusChange() {
        
        FirebaseMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { updatedMessage in

            if updatedMessage.status != kSENT {
                self.updateMessage(updatedMessage)
            }
        }
        
    }
    
    //MARK: - Actions
    
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
        
    }
    
    @objc private func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - Update typing indicator
    
    func createTypingObserver() {
        
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
            
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        
        typingCounter += 1
        
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        
        subTitleLabel.text = show ? "Typing..." : ""
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                //load earlier messages
                loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
        
    }
    
    //MARK: - Update Read Message status

    private func updateMessage(_ localMessage: LocalMessage) {
        
        for index in 0..<mkMessages.count {
            
            let tempMessage = mkMessages[index]
            
            if localMessage.id == tempMessage.messageId {
                
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                
                RealmManager.shared.saveToRealm(localMessage)
                
                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Helpers
    private func removeListeners() {
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeChatListeners()
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
        
    }
    
}

