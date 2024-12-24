// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedLibrary {
    // Book structure to store book details
    struct Book {
        uint256 id;
        string title;
        string author;
        address currentOwner;
        bool isAvailable;
    }

    // Mapping to store books by their unique ID
    mapping(uint256 => Book) public books;
    
    // Array to keep track of all book IDs
    uint256[] public bookIds;
    
    // Mapping to track books borrowed by users
    mapping(address => uint256[]) public userBorrowedBooks;

    // Events for important actions
    event BookAdded(uint256 bookId, string title, string author);
    event BookBorrowed(uint256 bookId, address borrower);
    event BookReturned(uint256 bookId, address returner);

    // Owner of the library contract
    address public librarian;

    constructor() {
        librarian = msg.sender;
    }

    // Modifier to restrict certain functions to the librarian
    modifier onlyLibrarian() {
        require(msg.sender == librarian, "Only the librarian can perform this action");
        _;
    }

    // Function to add a new book to the library
    function addBook(string memory _title, string memory _author) public onlyLibrarian returns (uint256) {
        uint256 bookId = bookIds.length + 1;
        
        books[bookId] = Book({
            id: bookId,
            title: _title,
            author: _author,
            currentOwner: address(0),
            isAvailable: true
        });
        
        bookIds.push(bookId);
        
        emit BookAdded(bookId, _title, _author);
        return bookId;
    }

    // Function to borrow a book
    function borrowBook(uint256 _bookId) public {
        require(_bookId > 0 && _bookId <= bookIds.length, "Invalid book ID");
        require(books[_bookId].isAvailable, "Book is not available");
        
        // Update book status
        books[_bookId].isAvailable = false;
        books[_bookId].currentOwner = msg.sender;
        
        // Add to user's borrowed books
        userBorrowedBooks[msg.sender].push(_bookId);
        
        emit BookBorrowed(_bookId, msg.sender);
    }

    // Function to return a book
    function returnBook(uint256 _bookId) public {
        require(_bookId > 0 && _bookId <= bookIds.length, "Invalid book ID");
        require(books[_bookId].currentOwner == msg.sender, "You did not borrow this book");
        
        // Update book status
        books[_bookId].isAvailable = true;
        books[_bookId].currentOwner = address(0);
        
        // Remove book from user's borrowed books
        _removeBookFromBorrowed(msg.sender, _bookId);
        
        emit BookReturned(_bookId, msg.sender);
    }

    // Internal function to remove a book from user's borrowed list
    function _removeBookFromBorrowed(address _user, uint256 _bookId) internal {
        uint256[] storage borrowedBooks = userBorrowedBooks[_user];
        for (uint256 i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                borrowedBooks[i] = borrowedBooks[borrowedBooks.length - 1];
                borrowedBooks.pop();
                break;
            }
        }
    }

    // Function to get total number of books
    function getTotalBooks() public view returns (uint256) {
        return bookIds.length;
    }

    // Function to get books borrowed by a user
    function getUserBorrowedBooks(address _user) public view returns (uint256[] memory) {
        return userBorrowedBooks[_user];
    }

    // Function to check if a book is available
    function isBookAvailable(uint256 _bookId) public view returns (bool) {
        require(_bookId > 0 && _bookId <= bookIds.length, "Invalid book ID");
        return books[_bookId].isAvailable;
    }
}