#!/bin/bash

# React + Vite Development Server Script
# Enhanced script with initialization, start/stop/restart functionality

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Function to check if sessions are running
check_sessions() {
    frontend_running=$(tmux list-sessions 2>/dev/null | grep "react-vite-frontend" | wc -l || echo "0")
}

# Function to stop sessions
stop_sessions() {
    print_info "Stopping React + Vite sessions..."
    tmux kill-session -t react-vite-frontend 2>/dev/null || true
    print_status "Sessions stopped"
}

# Function to check and setup environment
setup_environment() {
    print_info "Checking environment setup..."

    # Check if frontend dependencies are installed
    if [ ! -d "node_modules" ]; then
        print_warning "Dependencies not found. Installing..."
        npm install
        print_status "Dependencies installed"
    else
        print_status "Dependencies found"
    fi
}

# Function to start sessions
start_sessions() {
    check_sessions
    
    if [ "$frontend_running" -gt 0 ]; then
        print_warning "Session is already running. Restarting..."
        stop_sessions
        sleep 2
    fi

    print_info "Starting React + Vite project in tmux session..."

    # Start React + Vite frontend in tmux session  
    tmux new-session -d -s react-vite-frontend -c "$PROJECT_DIR" \
        'npm run dev'

    sleep 2  # Give session time to start
}

# Function to show status
show_status() {
    check_sessions
    echo
    print_info "React + Vite Project Status:"
    
    if [ "$frontend_running" -gt 0 ]; then
        print_status "Frontend: Running"
    else
        print_error "Frontend: Not running"
    fi
    
    echo
    if [ "$frontend_running" -gt 0 ]; then
        echo -e "${BLUE}Access the application:${NC}"
        echo "  🌐 Frontend (dev): http://localhost:5173"
        echo
        echo -e "${BLUE}Useful commands:${NC}"
        echo "  ./start-dev.sh status    - Show this status"
        echo "  ./start-dev.sh stop      - Stop all services"
        echo "  ./start-dev.sh restart   - Restart all services"
        echo "  tmux list-sessions       - List all tmux sessions"
        echo "  tmux attach-session -t react-vite-frontend - Attach to frontend"
    fi
}

# Function to show usage
show_usage() {
    echo "React + Vite Development Script"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  start     - Initialize environment and start services (default)"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  status    - Show current status"
    echo "  init      - Initialize environment only (no start)"
    echo "  help      - Show this help message"
    echo
}

# Main script logic
case "${1:-start}" in
    "start")
        setup_environment
        start_sessions
        show_status
        ;;
    "stop")
        stop_sessions
        show_status
        ;;
    "restart")
        setup_environment
        stop_sessions
        sleep 2
        start_sessions
        show_status
        ;;
    "status")
        show_status
        ;;
    "init")
        setup_environment
        print_status "Environment initialized. Run './start-dev.sh start' to start services."
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_usage
        exit 1
        ;;
esac
